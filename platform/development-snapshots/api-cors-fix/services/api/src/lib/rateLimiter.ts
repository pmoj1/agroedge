export class RateLimitError extends Error {
  statusCode = 429;
  constructor(message = 'Too many requests.') {
    super(message);
  }
}

interface Window {
  count: number;
  resetAt: number;
}

/**
 * Single-process, fixed-window limiter for the enumeration-risk single-
 * resource-by-id operations (get/update/delete). Deliberately not the same
 * mechanism as the global @fastify/rate-limit plugin (src/plugins/rate-
 * limit.ts): this one keys by authenticated user rather than IP, since it
 * runs after the security handler has resolved request.user.
 *
 * In-memory only -- fine for a single Railway instance (Phase 1). If the
 * API ever runs multiple instances, this needs to move to a shared store
 * (e.g. Redis) or the limit becomes per-instance instead of global.
 */
export class FixedWindowLimiter {
  #windows = new Map<string, Window>();

  constructor(
    private readonly max: number,
    private readonly windowMs: number,
  ) {}

  assert(key: string): void {
    const now = Date.now();
    const existing = this.#windows.get(key);

    if (!existing || existing.resetAt <= now) {
      this.#windows.set(key, { count: 1, resetAt: now + this.windowMs });
      return;
    }

    if (existing.count >= this.max) {
      throw new RateLimitError();
    }

    existing.count += 1;
  }
}
