import fp from 'fastify-plugin';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import type { FastifyInstance } from 'fastify';
import type { Config } from '../config.js';

declare module 'fastify' {
  interface FastifyInstance {
    supabase: SupabaseClient;
  }
}

/**
 * A single Supabase client using the service-role key. This key must never
 * reach a client -- it is loaded from the environment and only ever used
 * server-side (see root CLAUDE.md, "Data residency").
 *
 * RLS is still enabled on every table (db/CLAUDE.md) as a backstop, but the
 * service-role key bypasses it, so every handler MUST filter by owner_user
 * (or, for nested resources, by the parent's owner_user) itself. RLS is not
 * the enforcement layer here -- it protects any future access path that
 * doesn't go through this API.
 */
export default fp(async function supabasePlugin(fastify: FastifyInstance) {
  const config = fastify.config as Config;
  const client = createClient(config.supabaseUrl, config.supabaseServiceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  fastify.decorate('supabase', client);
});
