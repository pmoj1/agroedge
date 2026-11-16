import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { randomUUID } from 'node:crypto';

export function buildAdminClient(): SupabaseClient {
  return createClient(process.env.SUPABASE_URL as string, process.env.SUPABASE_SERVICE_ROLE_KEY as string, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

export interface TestFarmer {
  id: string;
  email: string;
  accessToken: string;
}

/**
 * Creates a throwaway auth.users row (via the admin API) plus the matching
 * public.users row every owner_user FK expects, then signs in to get a real
 * access token to send as `Authorization: Bearer` -- these tests exercise
 * src/plugins/auth.ts exactly as a client would, not a mocked JWT.
 */
export async function createTestFarmer(admin: SupabaseClient): Promise<TestFarmer> {
  const email = `test-${randomUUID()}@example.invalid`;
  const password = randomUUID();

  const { data: created, error: createError } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });
  if (createError || !created.user) {
    throw new Error(`Failed to create test farmer: ${createError?.message}`);
  }

  const { error: profileError } = await admin.from('users').insert({ id: created.user.id, email });
  if (profileError) {
    throw new Error(`Failed to seed public.users row: ${profileError.message}`);
  }

  const { data: session, error: signInError } = await admin.auth.signInWithPassword({ email, password });
  if (signInError || !session.session) {
    throw new Error(`Failed to sign in test farmer: ${signInError?.message}`);
  }

  return { id: created.user.id, email, accessToken: session.session.access_token };
}

/** Cascades (on delete cascade) take every owned row with it. */
export async function deleteTestFarmer(admin: SupabaseClient, id: string): Promise<void> {
  await admin.auth.admin.deleteUser(id);
}
