import { createHash } from 'node:crypto';
import type { SupabaseClient } from '@supabase/supabase-js';
import type { FastifyRequest } from 'fastify';

const IDEMPOTENCY_HEADER = 'idempotency-key';

function hashBody(body: unknown): string {
  return createHash('sha256').update(JSON.stringify(body ?? null)).digest('hex');
}

export interface IdempotentResult {
  status: number;
  body: unknown;
}

/**
 * Wraps a mutating handler (POST/PATCH/DELETE) with Idempotency-Key
 * support, backed by db/migrations/20260710010000_idempotency_keys_up.sql.
 *
 * Not part of the OpenAPI contract -- `Idempotency-Key` isn't declared as a
 * parameter in openapi.yaml, since changing the contract is its own PR
 * (packages/shared/CLAUDE.md). It's implemented as opt-in infrastructure
 * instead: a caller that doesn't send the header gets ordinary run-once
 * behaviour, unchanged. See the task's final report for why this was a
 * judgment call rather than a spec change.
 *
 * Mobile clients are offline-first and will retry a write after a dropped
 * connection without knowing whether the first attempt landed. If the same
 * (owner_user, method, route, key) has been seen before, the original
 * response is replayed instead of re-running the handler.
 *
 * Known limitation: two concurrent requests with the same brand-new key
 * can both pass the "not seen before" check and both run before either
 * insert lands (the unique constraint then rejects the second insert,
 * which is logged and swallowed rather than surfaced, so the second
 * caller sees its own fresh result rather than the first caller's). This
 * is an acceptable MVP gap for a farmer-facing retry button, not for a
 * payments-style exactly-once guarantee.
 */
export async function withIdempotency(
  supabase: SupabaseClient,
  request: FastifyRequest,
  ownerUser: string,
  run: () => Promise<IdempotentResult>,
): Promise<IdempotentResult> {
  const key = request.headers[IDEMPOTENCY_HEADER];
  if (!key || Array.isArray(key)) {
    return run();
  }

  const method = request.method;
  const route = request.routeOptions.url ?? request.url.split('?')[0] ?? request.url;
  const requestHash = hashBody(request.body);

  const { data: existing } = await supabase
    .from('idempotency_keys')
    .select('response_status, response_body, request_hash')
    .eq('owner_user', ownerUser)
    .eq('method', method)
    .eq('route', route)
    .eq('idempotency_key', key)
    .maybeSingle();

  if (existing) {
    if (existing.request_hash !== requestHash) {
      // Same key, different payload. We still replay the original response
      // rather than invent an undeclared conflict status code that isn't
      // part of the OpenAPI contract; the mismatch is logged (without the
      // request body, which may carry farm GPS data) so it's visible to
      // whoever is watching logs.
      request.log.warn({ route, method }, 'idempotency key reused with a different request body');
    }
    return { status: existing.response_status, body: existing.response_body };
  }

  const result = await run();

  const { error: insertError } = await supabase.from('idempotency_keys').insert({
    owner_user: ownerUser,
    idempotency_key: key,
    method,
    route,
    request_hash: requestHash,
    response_status: result.status,
    response_body: (result.body ?? null) as never,
  });

  if (insertError) {
    // Unique-violation from a concurrent duplicate request, or any other
    // storage failure -- either way the caller's own response is still
    // correct, so this is logged rather than turned into a 500.
    request.log.warn({ route, method, err: insertError.message }, 'failed to persist idempotency record');
  }

  return result;
}
