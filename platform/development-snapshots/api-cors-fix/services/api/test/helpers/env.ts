/**
 * Every integration/contract/RLS test in test/contract and test/rls needs a
 * real local Supabase instance (services/api/CLAUDE.md: "Integration tests
 * against a local Supabase"). This sandbox has neither the Supabase CLI nor
 * Docker installed, so those suites can't run *here* -- they're written to
 * run for real once a developer has `supabase start` running locally
 * (`supabase/config.toml` isn't part of this PR; see the final report for
 * why). Rather than fail red in every environment without Docker, each
 * suite checks reachability first and skips with a clear message.
 */
export async function supabaseAvailable(): Promise<boolean> {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) return false;

  try {
    const response = await fetch(new URL('/auth/v1/health', url), {
      signal: AbortSignal.timeout(1500),
    });
    return response.ok;
  } catch {
    return false;
  }
}
