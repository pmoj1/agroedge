import path from 'node:path';
import { fileURLToPath } from 'node:url';
import Fastify, { type FastifyInstance, type FastifyError } from 'fastify';
import openapiGlue from 'fastify-openapi-glue';

import { loadConfig } from './config.js';
import { buildLoggerOptions } from './logging.js';
import corsPlugin from './plugins/cors.js';
import supabasePlugin from './plugins/supabase.js';
import authPlugin, { SupabaseSecurityHandlers } from './plugins/auth.js';
import rateLimitPlugin from './plugins/rate-limit.js';
import { ApiError } from './lib/errors.js';
import { buildServiceHandlers } from './resources/index.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// The contract. services/api/CLAUDE.md: "If the spec and the implementation
// disagree, the implementation is wrong." fastify-openapi-glue generates
// every route, request schema and response schema straight from this file,
// so there is no separate hand-maintained route table to drift from it.
const OPENAPI_SPEC_PATH = path.resolve(
  __dirname,
  '../../../packages/shared/openapi/openapi.yaml',
);

export async function buildApp(): Promise<FastifyInstance> {
  const config = loadConfig();

  const fastify = Fastify({
    logger: buildLoggerOptions(config.logLevel),
  });

  fastify.decorate('config', config);

  await fastify.register(corsPlugin);
  await fastify.register(supabasePlugin);
  await fastify.register(authPlugin);
  await fastify.register(rateLimitPlugin);

  fastify.setErrorHandler((err: FastifyError | ApiError, request, reply) => {
    if (err instanceof ApiError) {
      reply.code(err.statusCode).send({ message: err.message, code: err.code });
      return;
    }

    // fastify-openapi-glue throws plain errors with a statusCode for
    // request-validation failures (400) and security-handler failures
    // (401); everything else is unexpected and must not leak internal
    // detail (Postgres error text, stack traces) to the caller.
    const statusCode = typeof err.statusCode === 'number' ? err.statusCode : 500;
    if (statusCode < 500) {
      reply.code(statusCode).send({ message: err.message, code: null });
      return;
    }

    request.log.error({ err }, 'unhandled error');
    reply.code(500).send({ message: 'Internal server error.', code: 'internal_error' });
  });

  await fastify.register(openapiGlue, {
    specification: OPENAPI_SPEC_PATH,
    serviceHandlers: buildServiceHandlers(fastify.supabase, {
      max: config.rateLimitStrictMax,
      windowMs: config.rateLimitStrictWindowMs,
    }),
    securityHandlers: new SupabaseSecurityHandlers(fastify.supabase),
  });

  return fastify;
}
