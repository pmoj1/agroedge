import { describe, expect, it, vi } from 'vitest';
import { FixedWindowLimiter, RateLimitError } from '../../src/lib/rateLimiter.js';

describe('FixedWindowLimiter', () => {
  it('allows up to max requests per key within the window', () => {
    const limiter = new FixedWindowLimiter(3, 60_000);
    expect(() => limiter.assert('user-a')).not.toThrow();
    expect(() => limiter.assert('user-a')).not.toThrow();
    expect(() => limiter.assert('user-a')).not.toThrow();
    expect(() => limiter.assert('user-a')).toThrow(RateLimitError);
  });

  it('tracks each key independently', () => {
    const limiter = new FixedWindowLimiter(1, 60_000);
    expect(() => limiter.assert('user-a')).not.toThrow();
    expect(() => limiter.assert('user-b')).not.toThrow();
    expect(() => limiter.assert('user-a')).toThrow(RateLimitError);
  });

  it('resets after the window elapses', () => {
    vi.useFakeTimers();
    try {
      const limiter = new FixedWindowLimiter(1, 1000);
      limiter.assert('user-a');
      expect(() => limiter.assert('user-a')).toThrow(RateLimitError);

      vi.advanceTimersByTime(1001);
      expect(() => limiter.assert('user-a')).not.toThrow();
    } finally {
      vi.useRealTimers();
    }
  });
});
