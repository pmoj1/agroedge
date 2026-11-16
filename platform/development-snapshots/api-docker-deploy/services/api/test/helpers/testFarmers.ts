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

  // A dedicated client for sign-in, not `admin`: calling auth.signInWith*
  // on a client mutates its session, and supabase-js then sends that
  // session's token instead of the client's original apikey/Authorization
  // header on every later request. Signing in on the shared `admin`
  // client would silently swap it from the service-role key to this one
  // farmer's own token -- breaking every subsequent admin call made
  // through it, including a second createTestFarmer() call sharing the
  // same admin client (its `users` insert would then run as this farmer,
  // an `authenticated` role with no BYPASSRLS and no INSERT policy on
  // `users`, and fail with an RLS violation instead of the real error).
  const signInClient = createClient(process.env.SUPABASE_URL as string, process.env.SUPABASE_SERVICE_ROLE_KEY as string, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data: session, error: signInError } = await signInClient.auth.signInWithPassword({ email, password });
  if (signInError || !session.session) {
    throw new Error(`Failed to sign in test farmer: ${signInError?.message}`);
  }

  return { id: created.user.id, email, accessToken: session.session.access_token };
}

/** Cascades (on delete cascade) take every owned row with it. */
export async function deleteTestFarmer(admin: SupabaseClient, id: string): Promise<void> {
  await admin.auth.admin.deleteUser(id);
}
