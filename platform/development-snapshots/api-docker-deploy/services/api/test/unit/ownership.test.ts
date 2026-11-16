import { describe, expect, it } from 'vitest';
import type { SupabaseClient } from '@supabase/supabase-js';
import { FakeSupabase } from '../helpers/fakeSupabase.js';
import { assertOwnsActivity } from '../../src/lib/ownership.js';
import { BadRequestError } from '../../src/lib/errors.js';

/**
 * assertOwnsActivity is the simple, single-table half of ownership.ts and
 * is fully covered here. assertOwnsActivityFile relies on a Postgrest
 * embedded-relation filter the fake query builder can't emulate
 * faithfully (see test/helpers/fakeSupabase.ts) -- it's covered against a
 * real Postgres instead, in test/rls/ownership.rls.test.ts's third case
 * ("cannot attach another farmer's activity_file as a receipt").
 */
describe('assertOwnsActivity', () => {
  it('resolves when the activity belongs to the caller', async () => {
    const fake = new FakeSupabase();
    fake.seed('activities', [{ id: 'act-1', owner_user: 'owner-a' }]);
    await expect(assertOwnsActivity(fake as unknown as SupabaseClient, 'owner-a', 'act-1')).resolves.toBeUndefined();
  });

  it('rejects with a 400 BadRequestError when the activity belongs to someone else', async () => {
    const fake = new FakeSupabase();
    fake.seed('activities', [{ id: 'act-1', owner_user: 'owner-b' }]);
    await expect(assertOwnsActivity(fake as unknown as SupabaseClient, 'owner-a', 'act-1')).rejects.toBeInstanceOf(
      BadRequestError,
    );
  });

  it('rejects when the activity id does not exist at all', async () => {
    const fake = new FakeSupabase();
    await expect(assertOwnsActivity(fake as unknown as SupabaseClient, 'owner-a', 'nonexistent')).rejects.toBeInstanceOf(
      BadRequestError,
    );
  });
});
