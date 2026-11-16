import fp from 'fastify-plugin';
import rateLimit from '@fastify/rate-limit';
import type { FastifyInstance } from 'fastify';
import type { Config } from '../config.js';

/**
 * Baseline rate limit applied to every route (services/api/CLAUDE.md: "Rate
 * limit everything"). Keyed by caller IP since this runs on Fastify's
 * onRequest hook, before the openapi-glue security handler has resolved
 * request.user.
 *
 * A second, tighter limit is applied inside src/lib/resource.ts and
 * src/lib/nestedResource.ts specifically to single-resource-by-id
 * operations (get/update/delete), keyed by the authenticated user, since
 * those are the operations an attacker would hammer to enumerate valid
 * UUIDs by watching for 200 vs 404. List/create endpoints only ever
 * return the caller's own rows, so they don't carry that enumeration risk.
 */
export default fp(async function rateLimitPlugin(fastify: FastifyInstance) {
  const config = fastify.config as Config;
  await fastify.register(rateLimit, {
    max: config.rateLimitMax,
    timeWindow: config.rateLimitWindowMs,
    hook: 'onRequest',
    keyGenerator: (request) => request.ip,
  });
});
