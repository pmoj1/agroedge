import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['test/**/*.test.ts'],
    testTimeout: 15000,
    env: {
      // The by-id rate limiter (src/lib/rateLimiter.ts) is shared across all
      // 14 resources for one authenticated user, by design -- a real
      // farmer legitimately won't make 30+ single-resource lookups in a
      // minute, but the contract suite walks all 14 resources' full CRUD
      // lifecycle back to back with one test farmer, which does. Loosen it
      // here so the suite tests contract shape, not rate-limit behavior --
      // rate limiting itself has its own coverage in test/unit/rateLimiter.test.ts.
      RATE_LIMIT_STRICT_MAX: '10000',
      RATE_LIMIT_STRICT_WINDOW_MS: '60000',
    },
  },
});
