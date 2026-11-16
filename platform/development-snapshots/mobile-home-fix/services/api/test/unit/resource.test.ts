import { describe, expect, it, beforeEach } from 'vitest';
import type { SupabaseClient } from '@supabase/supabase-js';
import type { FastifyReply, FastifyRequest } from 'fastify';
import { FakeSupabase } from '../helpers/fakeSupabase.js';
import { createOwnedResourceHandlers } from '../../src/lib/resource.js';
import { NotFoundError, BadRequestError } from '../../src/lib/errors.js';
import { FixedWindowLimiter } from '../../src/lib/rateLimiter.js';

function makeRequest(opts: {
  user: { id: string } | null;
  params?: Record<string, string>;
  query?: Record<string, unknown>;
  body?: unknown;
  headers?: Record<string, string>;
  method?: string;
}): FastifyRequest {
  return {
    user: opts.user,
    params: opts.params ?? {},
    query: opts.query ?? { limit: 50, offset: 0 },
    body: opts.body,
    headers: opts.headers ?? {},
    method: opts.method ?? 'GET',
    url: '/test',
    routeOptions: { url: '/test' },
    log: { warn() {}, error() {} },
  } as unknown as FastifyRequest;
}

function makeReply(): FastifyReply & { statusCode: number } {
  const reply = {
    statusCode: 200,
    code(code: number) {
      reply.statusCode = code;
      return reply;
    },
  };
  return reply as unknown as FastifyReply & { statusCode: number };
}

describe('createOwnedResourceHandlers (authorization logic, no live DB)', () => {
  let fake: FakeSupabase;
  let handlers: ReturnType<typeof createOwnedResourceHandlers>;
  const ownerA = 'user-a';
  const ownerB = 'user-b';

  beforeEach(() => {
    fake = new FakeSupabase();
    handlers = createOwnedResourceHandlers(
      fake as unknown as SupabaseClient,
      {
        table: 'farm_profiles',
        columns: ['id', 'owner_user', 'farm_name', 'created_at', 'updated_at'],
        createFields: ['farm_name'],
        updateFields: ['farm_name'],
        hasUpdatedAt: true,
      },
      new FixedWindowLimiter(1000, 60_000),
    );
  });

  it('create() sets owner_user from the authenticated caller, ignoring any owner_user in the body', async () => {
    const request = makeRequest({
      user: { id: ownerA },
      body: { farm_name: 'Mine', owner_user: ownerB },
    });
    const result = await handlers.create(request, makeReply());
    expect((result as unknown as { owner_user: string }).owner_user).toBe(ownerA);
    expect((result as unknown as { farm_name: string }).farm_name).toBe('Mine');
  });

  it('list() only returns the caller\'s own rows', async () => {
    fake.seed('farm_profiles', [
      { id: '1', owner_user: ownerA, farm_name: 'A1', created_at: '2026-01-01' },
      { id: '2', owner_user: ownerB, farm_name: 'B1', created_at: '2026-01-02' },
      { id: '3', owner_user: ownerA, farm_name: 'A2', created_at: '2026-01-03' },
    ]);

    const result = (await handlers.list(makeRequest({ user: { id: ownerA } }), makeReply())) as unknown as {
      data: Array<{ owner_user: string }>;
      total: number;
    };

    expect(result.total).toBe(2);
    expect(result.data.every((row) => row.owner_user === ownerA)).toBe(true);
  });

  it('get() throws NotFoundError for a row owned by someone else', async () => {
    fake.seed('farm_profiles', [{ id: '1', owner_user: ownerB, farm_name: "B's farm", created_at: '2026-01-01' }]);

    await expect(handlers.get(makeRequest({ user: { id: ownerA }, params: { id: '1' } }), makeReply())).rejects.toBeInstanceOf(
      NotFoundError,
    );
  });

  it('get() returns the row when the caller is the owner', async () => {
    fake.seed('farm_profiles', [{ id: '1', owner_user: ownerA, farm_name: "A's farm", created_at: '2026-01-01' }]);

    const result = await handlers.get(makeRequest({ user: { id: ownerA }, params: { id: '1' } }), makeReply());
    expect((result as unknown as { farm_name: string }).farm_name).toBe("A's farm");
  });

  it('update() cannot modify a row owned by someone else, even with a valid id', async () => {
    fake.seed('farm_profiles', [{ id: '1', owner_user: ownerB, farm_name: 'original', created_at: '2026-01-01' }]);

    await expect(
      handlers.update(
        makeRequest({ user: { id: ownerA }, params: { id: '1' }, body: { farm_name: 'hijacked' } }),
        makeReply(),
      ),
    ).rejects.toBeInstanceOf(NotFoundError);

    expect(fake.rows('farm_profiles')[0]?.farm_name).toBe('original');
  });

  it('update() bumps updated_at when hasUpdatedAt is set', async () => {
    fake.seed('farm_profiles', [{ id: '1', owner_user: ownerA, farm_name: 'x', updated_at: '2020-01-01T00:00:00.000Z' }]);

    const result = await handlers.update(
      makeRequest({ user: { id: ownerA }, params: { id: '1' }, body: { farm_name: 'y' } }),
      makeReply(),
    );
    expect((result as unknown as { updated_at: string }).updated_at).not.toBe('2020-01-01T00:00:00.000Z');
  });

  it('remove() cannot delete a row owned by someone else', async () => {
    fake.seed('farm_profiles', [{ id: '1', owner_user: ownerB, farm_name: 'still here' }]);

    await expect(
      handlers.remove(makeRequest({ user: { id: ownerA }, params: { id: '1' } }), makeReply()),
    ).rejects.toBeInstanceOf(NotFoundError);
    expect(fake.rows('farm_profiles')).toHaveLength(1);
  });

  it('remove() returns undefined (empty body) on success, never the literal null', async () => {
    fake.seed('farm_profiles', [{ id: '1', owner_user: ownerA }]);
    const result = await handlers.remove(makeRequest({ user: { id: ownerA }, params: { id: '1' } }), makeReply());
    expect(result).toBeUndefined();
  });

  it('a unique-violation on create maps to a 400 BadRequestError, not a 500', async () => {
    const uniqueHandlers = createOwnedResourceHandlers(
      fake as unknown as SupabaseClient,
      {
        table: 'communication_preferences',
        columns: ['id', 'owner_user'],
        createFields: [],
        updateFields: [],
        uniqueViolationMessage: 'already exists',
      },
      new FixedWindowLimiter(1000, 60_000),
    );
    fake.setUniqueKeys('communication_preferences', [['owner_user']]);
    fake.seed('communication_preferences', [{ id: '1', owner_user: ownerA }]);

    await expect(
      uniqueHandlers.create(makeRequest({ user: { id: ownerA }, body: {} }), makeReply()),
    ).rejects.toBeInstanceOf(BadRequestError);
  });
});
