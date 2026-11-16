import { describe, expect, it } from 'vitest';
import type { SupabaseClient } from '@supabase/supabase-js';
import type { FastifyRequest } from 'fastify';
import { FakeSupabase } from '../helpers/fakeSupabase.js';
import { withIdempotency } from '../../src/lib/idempotency.js';

function makeRequest(headers: Record<string, string>, body: unknown): FastifyRequest {
  return {
    headers,
    body,
    method: 'POST',
    url: '/season-budgets',
    routeOptions: { url: '/season-budgets' },
    log: { warn() {}, error() {} },
  } as unknown as FastifyRequest;
}

describe('withIdempotency', () => {
  it('runs the handler once and replays the cached response for a retried key', async () => {
    const fake = new FakeSupabase();
    let calls = 0;
    const run = async () => {
      calls += 1;
      return { status: 201, body: { id: `created-${calls}` } };
    };

    const first = await withIdempotency(fake as unknown as SupabaseClient, makeRequest({ 'idempotency-key': 'abc' }, { a: 1 }), 'owner-a', run);
    expect(first.body).toEqual({ id: 'created-1' });

    const second = await withIdempotency(fake as unknown as SupabaseClient, makeRequest({ 'idempotency-key': 'abc' }, { a: 1 }), 'owner-a', run);
    expect(second).toEqual(first);
    expect(calls).toBe(1);
  });

  it('without a header, runs the handler every time (no caching)', async () => {
    const fake = new FakeSupabase();
    let calls = 0;
    const run = async () => {
      calls += 1;
      return { status: 201, body: { id: `x${calls}` } };
    };

    await withIdempotency(fake as unknown as SupabaseClient, makeRequest({}, {}), 'owner-a', run);
    await withIdempotency(fake as unknown as SupabaseClient, makeRequest({}, {}), 'owner-a', run);
    expect(calls).toBe(2);
  });

  it('scopes the cache by owner -- a different owner with the same key runs independently', async () => {
    const fake = new FakeSupabase();
    let calls = 0;
    const run = async () => {
      calls += 1;
      return { status: 201, body: { id: `y${calls}` } };
    };

    await withIdempotency(fake as unknown as SupabaseClient, makeRequest({ 'idempotency-key': 'shared' }, {}), 'owner-a', run);
    await withIdempotency(fake as unknown as SupabaseClient, makeRequest({ 'idempotency-key': 'shared' }, {}), 'owner-b', run);
    expect(calls).toBe(2);
  });
});
