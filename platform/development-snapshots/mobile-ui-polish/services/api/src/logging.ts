import type { FastifyBaseLogger, FastifyServerOptions } from 'fastify';

/**
 * Structured JSON logging, redact-by-default. Root CLAUDE.md: "Never log
 * PII to third-party services. Never log phone numbers, national IDs, or
 * precise GPS." This API surface doesn't handle phone/national ID at all
 * (those live on auth.users / a future personal-identifiers table, not in
 * this contract), but farm_profiles and activities do carry gps_lat/gps_lng,
 * so request/response bodies are never logged wholesale -- only the
 * allowlisted fields below.
 *
 * `redact` is defense in depth: nothing here currently logs headers or
 * bodies directly, but if that ever changes, these paths are stripped
 * before they reach the log sink rather than relying on every future
 * call site remembering to omit them.
 */
export function buildLoggerOptions(logLevel: string): FastifyServerOptions['logger'] {
  return {
    level: logLevel,
    redact: {
      paths: [
        'req.headers.authorization',
        'req.headers.cookie',
        'req.headers["set-cookie"]',
        '*.gps_lat',
        '*.gps_lng',
        '*.phone',
        '*.national_id',
      ],
      censor: '[redacted]',
    },
    serializers: {
      req(request: { method: string; routeOptions?: { url?: string }; url: string; id: string | number }) {
        return {
          method: request.method,
          // route pattern, not raw url -- avoids logging query strings verbatim.
          route: request.routeOptions?.url ?? request.url.split('?')[0],
          requestId: request.id,
        };
      },
      res(reply: { statusCode: number }) {
        return {
          statusCode: reply.statusCode,
        };
      },
    },
  };
}

export type Logger = FastifyBaseLogger;
