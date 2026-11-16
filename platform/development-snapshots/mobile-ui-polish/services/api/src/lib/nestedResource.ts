import type { SupabaseClient, PostgrestError } from '@supabase/supabase-js';
import type { FastifyReply, FastifyRequest } from 'fastify';
import { NotFoundError } from './errors.js';
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

function assertNoDbError(error: PostgrestError | null): void {
  if (!error) return;
  throw new Error(`Database error on ${error.code ?? 'unknown'}: ${error.message}`);
}

export interface NestedResourceConfig {
  /** Postgres table name, e.g. 'activity_files'. */
  table: string;
  /** Parent table name, e.g. 'activities'. */
  parentTable: string;
  /** Fastify path param carrying the parent id, e.g. 'activityId'. */
  parentIdParam: string;
  /** Column on `table` that references the parent, e.g. 'activity_id'. */
  foreignKey: string;
  columns: readonly string[];
  createFields: readonly string[];
  updateFields: readonly string[];
  orderColumn?: string;
}

/**
 * CRUD handlers for a table with no direct owner_user column, whose RLS
 * policy is instead a join to its parent's owner_user (see
 * activity_files_owner / notification_delivery_logs_owner in
 * db/migrations/20260710000000_init_schema_up.sql). The service-role key
 * bypasses that policy, so every method here re-checks the same join
 * itself: does the parent row (identified by the path param) belong to
 * the caller? If not, 404 -- same as the flat-resource case, a row that
 * exists but belongs to someone else is indistinguishable from a row that
 * doesn't exist.
 */
export function createNestedResourceHandlers(
  supabase: SupabaseClient,
  config: NestedResourceConfig,
  byIdLimiter: FixedWindowLimiter,
) {
  const orderColumn = config.orderColumn ?? 'created_at';
  const selectColumns = config.columns.join(',');

  function requireUser(request: FastifyRequest): string {
    if (!request.user) {
      throw new Error('Handler invoked without an authenticated user.');
    }
    return request.user.id;
  }

  async function assertOwnsParent(ownerUser: string, parentId: string): Promise<void> {
    const { data, error } = await supabase
      .from(config.parentTable)
      .select('id')
      .eq('id', parentId)
      .eq('owner_user', ownerUser)
      .maybeSingle();

    assertNoDbError(error);
    if (!data) throw new NotFoundError();
  }

  return {
    async list(request: FastifyRequest, _reply: FastifyReply) {
      const ownerUser = requireUser(request);
      const params = request.params as Record<string, string>;
      const parentId = params[config.parentIdParam] as string;
      await assertOwnsParent(ownerUser, parentId);

      const query = request.query as { limit: number; offset: number };
      const { limit, offset } = query;

      const { data, error, count } = await supabase
        .from(config.table)
        .select(selectColumns, { count: 'exact' })
        .eq(config.foreignKey, parentId)
        .order(orderColumn, { ascending: false })
        .range(offset, offset + limit - 1);

      assertNoDbError(error);
      return { data: data ?? [], limit, offset, total: count ?? 0 };
    },

    async create(request: FastifyRequest, reply: FastifyReply) {
      const ownerUser = requireUser(request);
      const params = request.params as Record<string, string>;
      const parentId = params[config.parentIdParam] as string;
      const body = (request.body ?? {}) as Record<string, unknown>;
      const fields = pick(body, config.createFields);

      const result = await withIdempotency(supabase, request, ownerUser, async () => {
        await assertOwnsParent(ownerUser, parentId);

        const { data, error } = await supabase
          .from(config.table)
          .insert({ ...fields, [config.foreignKey]: parentId })
          .select(selectColumns)
          .single();

        assertNoDbError(error);
        return { status: 201, body: data };
      });

      reply.code(result.status);
      return result.body;
    },

    async get(request: FastifyRequest, _reply: FastifyReply) {
      const ownerUser = requireUser(request);
      byIdLimiter.assert(ownerUser);
      const params = request.params as Record<string, string>;
      const parentId = params[config.parentIdParam] as string;
      const { id } = request.params as { id: string };
      await assertOwnsParent(ownerUser, parentId);

      const { data, error } = await supabase
        .from(config.table)
        .select(selectColumns)
        .eq('id', id)
        .eq(config.foreignKey, parentId)
        .maybeSingle();

      assertNoDbError(error);
      if (!data) throw new NotFoundError();
      return data;
    },

    async update(request: FastifyRequest, reply: FastifyReply) {
      const ownerUser = requireUser(request);
      byIdLimiter.assert(ownerUser);
      const params = request.params as Record<string, string>;
      const parentId = params[config.parentIdParam] as string;
      const { id } = request.params as { id: string };
      const body = (request.body ?? {}) as Record<string, unknown>;
      const fields = pick(body, config.updateFields);

      const result = await withIdempotency(supabase, request, ownerUser, async () => {
        await assertOwnsParent(ownerUser, parentId);

        const { data, error } = await supabase
          .from(config.table)
          .update(fields)
          .eq('id', id)
          .eq(config.foreignKey, parentId)
          .select(selectColumns)
          .maybeSingle();

        assertNoDbError(error);
        if (!data) throw new NotFoundError();
        return { status: 200, body: data };
      });

      reply.code(result.status);
      return result.body;
    },

    async remove(request: FastifyRequest, reply: FastifyReply) {
      const ownerUser = requireUser(request);
      byIdLimiter.assert(ownerUser);
      const params = request.params as Record<string, string>;
      const parentId = params[config.parentIdParam] as string;
      const { id } = request.params as { id: string };

      const result = await withIdempotency(supabase, request, ownerUser, async () => {
        await assertOwnsParent(ownerUser, parentId);

        const { data, error } = await supabase
          .from(config.table)
          .delete()
          .eq('id', id)
          .eq(config.foreignKey, parentId)
          .select('id')
          .maybeSingle();

        assertNoDbError(error);
        if (!data) throw new NotFoundError();
        return { status: 204, body: undefined };
      });

      reply.code(result.status);
      return result.status === 204 ? undefined : result.body;
    },
  };
}
