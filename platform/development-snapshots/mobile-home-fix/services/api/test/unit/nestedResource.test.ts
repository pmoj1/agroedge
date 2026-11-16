import { describe, expect, it, beforeEach } from 'vitest';
import type { SupabaseClient } from '@supabase/supabase-js';
import type { FastifyReply, FastifyRequest } from 'fastify';
import { FakeSupabase } from '../helpers/fakeSupabase.js';
import { createNestedResourceHandlers } from '../../src/lib/nestedResource.js';
import { NotFoundError } from '../../src/lib/errors.js';
import { FixedWindowLimiter } from '../../src/lib/rateLimiter.js';

function makeRequest(opts: {
  user: { id: string } | null;
  params?: Record<string, string>;
  query?: Record<string, unknown>;
  body?: unknown;
  headers?: Record<string, string>;
}): FastifyRequest {
  return {
    user: opts.user,
    params: opts.params ?? {},
    query: opts.query ?? { limit: 50, offset: 0 },
    body: opts.body,
    headers: opts.headers ?? {},
    method: 'GET',
    url: '/test',
    routeOptions: { url: '/test' },
    log: { warn() {}, error() {} },
  } as unknown as FastifyRequest;
}

function makeReply(): FastifyReply {
  const reply = { code: () => reply };
  return reply as unknown as FastifyReply;
}

describe('createNestedResourceHandlers (parent-ownership logic, no live DB)', () => {
  let fake: FakeSupabase;
  let handlers: ReturnType<typeof createNestedResourceHandlers>;
  const ownerA = 'user-a';
  const ownerB = 'user-b';

  beforeEach(() => {
    fake = new FakeSupabase();
    handlers = createNestedResourceHandlers(
      fake as unknown as SupabaseClient,
      {
        table: 'activity_files',
        parentTable: 'activities',
        parentIdParam: 'activityId',
        foreignKey: 'activity_id',
        columns: ['id', 'activity_id', 'storage_path', 'created_at'],
        createFields: ['storage_path'],
        updateFields: ['storage_path'],
      },
      new FixedWindowLimiter(1000, 60_000),
    );

    fake.seed('activities', [
      { id: 'act-a', owner_user: ownerA },
      { id: 'act-b', owner_user: ownerB },
    ]);
    fake.seed('activity_files', [
      { id: 'file-a', activity_id: 'act-a', storage_path: 'a.jpg', created_at: '2026-01-01' },
      { id: 'file-b', activity_id: 'act-b', storage_path: 'b.jpg', created_at: '2026-01-01' },
    ]);
  });

  it('list() 404s when the caller does not own the parent activity', async () => {
    await expect(
      handlers.list(makeRequest({ user: { id: ownerA }, params: { activityId: 'act-b' } }), makeReply()),
    ).rejects.toBeInstanceOf(NotFoundError);
  });

  it('list() succeeds and is scoped to the parent when the caller owns it', async () => {
    const result = (await handlers.list(
      makeRequest({ user: { id: ownerA }, params: { activityId: 'act-a' } }),
      makeReply(),
    )) as unknown as { data: Array<{ id: string }>; total: number };
    expect(result.total).toBe(1);
    expect(result.data[0]?.id).toBe('file-a');
  });

  it('get() 404s for a file that exists but hangs off a parent the caller does not own', async () => {
    // act-b's file, but the caller passes act-a as the parent id in the URL
    // -- this must still 404 rather than leak file-b by id lookup alone.
    await expect(
      handlers.get(
        makeRequest({ user: { id: ownerA }, params: { activityId: 'act-a', id: 'file-b' } }),
        makeReply(),
      ),
    ).rejects.toBeInstanceOf(NotFoundError);
  });

  it('get() 404s outright when the caller does not own the parent, regardless of file id', async () => {
    await expect(
      handlers.get(
        makeRequest({ user: { id: ownerA }, params: { activityId: 'act-b', id: 'file-b' } }),
        makeReply(),
      ),
    ).rejects.toBeInstanceOf(NotFoundError);
  });

  it('create() attaches the new file to the given parent via the foreign key', async () => {
    const result = await handlers.create(
      makeRequest({ user: { id: ownerA }, params: { activityId: 'act-a' }, body: { storage_path: 'new.jpg' } }),
      makeReply(),
    );
    expect((result as unknown as { activity_id: string }).activity_id).toBe('act-a');
  });

  it('create() is rejected when the caller does not own the target parent', async () => {
    await expect(
      handlers.create(
        makeRequest({ user: { id: ownerA }, params: { activityId: 'act-b' }, body: { storage_path: 'x.jpg' } }),
        makeReply(),
      ),
    ).rejects.toBeInstanceOf(NotFoundError);
  });
});
