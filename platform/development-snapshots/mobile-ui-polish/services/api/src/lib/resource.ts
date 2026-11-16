import type { SupabaseClient, PostgrestError } from '@supabase/supabase-js';
import type { FastifyReply, FastifyRequest } from 'fastify';
import { BadRequestError, NotFoundError } from './errors.js';
import { withIdempotency } from './idempotency.js';
import { FixedWindowLimiter } from './rateLimiter.js';

function pick(body: Record<string, unknown>, fields: readonly string[]): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const field of fields) {
    if (Object.prototype.hasOwnProperty.call(body, field)) {
      out[field] = body[field];
    }
  }
  return out;
}

function assertNoDbError(error: PostgrestError | null, uniqueViolationMessage?: string): void {
  if (!error) return;
  if (error.code === '23505' && uniqueViolationMessage) {
    throw new BadRequestError(uniqueViolationMessage, 'already_exists');
  }
  throw new Error(`Database error on ${error.code ?? 'unknown'}: ${error.message}`);
}

export interface ResourceConfig {
  /** Postgres table name. */
  table: string;
  /** Explicit column allowlist for SELECT -- db/CLAUDE.md: no `select('*')`. */
  columns: readonly string[];
  createFields: readonly string[];
  updateFields: readonly string[];
  /** Column used to order list results. Defaults to 'created_at'. */
  orderColumn?: string;
  /** True for the (small number of) tables with an `updated_at` column that
   * has no DB trigger to bump it automatically -- the API sets it by hand
   * on every PATCH. */
  hasUpdatedAt?: boolean;
  /** Set for tables with a unique constraint on owner_user (currently only
   * communication_preferences), so a duplicate create returns a 400
   * ValidationError -- one of the response codes the spec already declares
   * for POST -- instead of an undeclared 409/500. */
  uniqueViolationMessage?: string;
  /** Ownership checks for foreign-key fields that point at other farmer-
   * owned rows (e.g. Expense.receipt_file_id). Runs before insert/update. */
  onBeforeWrite?: (supabase: SupabaseClient, ownerUser: string, fields: Record<string, unknown>) => Promise<void>;
}

/**
 * CRUD handlers for a table with a direct `owner_user` column, mirroring
 * the `for all using (auth.uid() = owner_user)` RLS policy created for
 * every one of these tables in db/migrations/20260710000000_init_schema_up.sql.
 * The service-role key bypasses that policy (src/plugins/supabase.ts), so
 * every method below re-implements the same check at the API layer.
 */
export function createOwnedResourceHandlers(
  supabase: SupabaseClient,
  config: ResourceConfig,
  byIdLimiter: FixedWindowLimiter,
) {
  const orderColumn = config.orderColumn ?? 'created_at';
  const selectColumns = config.columns.join(',');

  function requireUser(request: FastifyRequest): string {
    // The security handler (src/plugins/auth.ts) guarantees request.user is
    // set before any service handler runs; this is a defensive assertion,
    // not the authorization check itself.
    if (!request.user) {
      throw new Error('Handler invoked without an authenticated user.');
    }
    return request.user.id;
  }

  return {
    async list(request: FastifyRequest, _reply: FastifyReply) {
      const ownerUser = requireUser(request);
      const query = request.query as { limit: number; offset: number };
      const { limit, offset } = query;

      const { data, error, count } = await supabase
        .from(config.table)
        .select(selectColumns, { count: 'exact' })
        .eq('owner_user', ownerUser)
        .order(orderColumn, { ascending: false })
        .range(offset, offset + limit - 1);

      assertNoDbError(error);

      return { data: data ?? [], limit, offset, total: count ?? 0 };
    },

    async create(request: FastifyRequest, reply: FastifyReply) {
      const ownerUser = requireUser(request);
      const body = (request.body ?? {}) as Record<string, unknown>;
      const fields = pick(body, config.createFields);

      const result = await withIdempotency(supabase, request, ownerUser, async () => {
        if (config.onBeforeWrite) {
          await config.onBeforeWrite(supabase, ownerUser, fields);
        }

        const { data, error } = await supabase
          .from(config.table)
          .insert({ ...fields, owner_user: ownerUser })
          .select(selectColumns)
          .single();

        assertNoDbError(error, config.uniqueViolationMessage);
        return { status: 201, body: data };
      });

      reply.code(result.status);
      return result.body;
    },

    async get(request: FastifyRequest, _reply: FastifyReply) {
      const ownerUser = requireUser(request);
      byIdLimiter.assert(ownerUser);
      const { id } = request.params as { id: string };

      const { data, error } = await supabase
        .from(config.table)
        .select(selectColumns)
        .eq('id', id)
        .eq('owner_user', ownerUser)
        .maybeSingle();

      assertNoDbError(error);
      if (!data) throw new NotFoundError();
      return data;
    },

    async update(request: FastifyRequest, reply: FastifyReply) {
      const ownerUser = requireUser(request);
      byIdLimiter.assert(ownerUser);
      const { id } = request.params as { id: string };
      const body = (request.body ?? {}) as Record<string, unknown>;
      const fields = pick(body, config.updateFields);

      const result = await withIdempotency(supabase, request, ownerUser, async () => {
        if (config.onBeforeWrite) {
          await config.onBeforeWrite(supabase, ownerUser, fields);
        }

        const patch = config.hasUpdatedAt ? { ...fields, updated_at: new Date().toISOString() } : fields;

        const { data, error } = await supabase
          .from(config.table)
          .update(patch)
          .eq('id', id)
          .eq('owner_user', ownerUser)
          .select(selectColumns)
          .maybeSingle();

        assertNoDbError(error, config.uniqueViolationMessage);
        if (!data) throw new NotFoundError();
        return { status: 200, body: data };
      });

      reply.code(result.status);
      return result.body;
    },

    async remove(request: FastifyRequest, reply: FastifyReply) {
      const ownerUser = requireUser(request);
      byIdLimiter.assert(ownerUser);
      const { id } = request.params as { id: string };

      const result = await withIdempotency(supabase, request, ownerUser, async () => {
        const { data, error } = await supabase
          .from(config.table)
          .delete()
          .eq('id', id)
          .eq('owner_user', ownerUser)
          .select('id')
          .maybeSingle();

        assertNoDbError(error);
        if (!data) throw new NotFoundError();
        return { status: 204, body: undefined };
      });

      // A 204 must not carry a body -- reply.send(undefined) sends an empty
      // body, reply.send(null) would send the literal text "null".
      reply.code(result.status);
      return result.status === 204 ? undefined : result.body;
    },
  };
}
