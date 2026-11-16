function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function int(name: string, fallback: number): number {
  const raw = process.env[name];
  if (!raw) return fallback;
  const parsed = Number.parseInt(raw, 10);
  if (Number.isNaN(parsed)) {
    throw new Error(`Environment variable ${name} must be an integer, got "${raw}"`);
  }
  return parsed;
}

declare module 'fastify' {
  interface FastifyInstance {
    config: Config;
  }
}

const DEFAULT_CORS_ORIGINS = ['http://localhost:8080', 'http://localhost:3000'];

function corsOrigins(name: string, fallback: string[]): string[] {
  const raw = process.env[name];
  if (!raw) return fallback;
  return raw
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
}

export interface Config {
  port: number;
  host: string;
  logLevel: string;
  supabaseUrl: string;
  supabaseServiceRoleKey: string;
  rateLimitMax: number;
  rateLimitWindowMs: number;
  rateLimitStrictMax: number;
  rateLimitStrictWindowMs: number;
  corsOrigins: string[];
}

export function loadConfig(): Config {
  return {
    port: int('PORT', 3000),
    host: process.env.HOST ?? '0.0.0.0',
    logLevel: process.env.LOG_LEVEL ?? 'info',
    // Server-side only. Never forwarded to a client, never logged.
    supabaseUrl: required('SUPABASE_URL'),
    supabaseServiceRoleKey: required('SUPABASE_SERVICE_ROLE_KEY'),
    rateLimitMax: int('RATE_LIMIT_MAX', 300),
    rateLimitWindowMs: int('RATE_LIMIT_WINDOW_MS', 60_000),
    rateLimitStrictMax: int('RATE_LIMIT_STRICT_MAX', 30),
    rateLimitStrictWindowMs: int('RATE_LIMIT_STRICT_WINDOW_MS', 60_000),
    // Comma-separated list of allowed origins, e.g.
    // "https://dashboard.agroedge.co,https://app.agroedge.co". Defaults to
    // local dev origins for the mobile app and the API's own host.
    corsOrigins: corsOrigins('CORS_ORIGINS', DEFAULT_CORS_ORIGINS),
  };
}
