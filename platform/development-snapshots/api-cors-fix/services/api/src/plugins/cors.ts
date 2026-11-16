import fp from 'fastify-plugin';
import cors, { type OriginFunction } from '@fastify/cors';
import type { FastifyInstance } from 'fastify';
import type { Config } from '../config.js';
import { ApiError } from '../lib/errors.js';

/**
 * Restricts cross-origin requests to the allowlist in Config.corsOrigins
 * (env var CORS_ORIGINS, defaults to the mobile app's local dev origin and
 * the API's own host). Must register before openapi-glue so its OPTIONS
 * preflight handling is in place before routes are added.
 */
export default fp(async function corsPlugin(fastify: FastifyInstance) {
  const config = fastify.config as Config;
  const allowedOrigins = new Set(config.corsOrigins);

  const originCheck: OriginFunction = (origin, callback) => {
    if (!origin || allowedOrigins.has(origin)) {
      callback(null, true);
      return;
    }
    callback(new ApiError(403, `Origin ${origin} is not allowed by CORS policy.`, 'cors_forbidden'), false);
  };

  await fastify.register(cors, { origin: originCheck });
});
