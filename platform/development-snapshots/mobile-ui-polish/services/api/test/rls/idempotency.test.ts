import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { randomUUID } from 'node:crypto';
import { buildApp } from '../../src/app.js';
import { supabaseAvailable } from '../helpers/env.js';
import { buildAdminClient, createTestFarmer, deleteTestFarmer, type TestFarmer } from '../helpers/testFarmers.js';

let available = false;

beforeAll(async () => {
  available = await supabaseAvailable();
});

describe('Idempotency-Key on write endpoints', () => {
  let app: FastifyInstance;
  let admin: ReturnType<typeof buildAdminClient>;
  let farmer: TestFarmer;

  beforeAll(async () => {
    if (!available) return;
    admin = buildAdminClient();
    farmer = await createTestFarmer(admin);
    app = await buildApp();
  });

  afterAll(async () => {
    if (!available) return;
    await app.close();
    await deleteTestFarmer(admin, farmer.id);
  });

  it('retrying a POST with the same Idempotency-Key does not create a second row', async () => {
    if (!available) {
      console.warn('SUPABASE_URL not reachable -- skipping idempotency test. Run `supabase start` locally to execute this suite.');
      return;
    }

    const key = randomUUID();
    const headers = { authorization: `Bearer ${farmer.accessToken}`, 'idempotency-key': key };
    const payload = { season_label: 'idempotency-test-season', budget_amount: 500 };

    const first = await app.inject({ method: 'POST', url: '/season-budgets', headers, payload });
    expect(first.statusCode).toBe(201);
    const firstBody = first.json();

    const second = await app.inject({ method: 'POST', url: '/season-budgets', headers, payload });
    expect(second.statusCode).toBe(201);
    const secondBody = second.json();

    // Same id back -- the second attempt replayed the cached response
    // rather than inserting a new row (see src/lib/idempotency.ts).
    expect(secondBody.id).toBe(firstBody.id);

    const list = await app.inject({
      method: 'GET',
      url: '/season-budgets?limit=200',
      headers: { authorization: `Bearer ${farmer.accessToken}` },
    });
    const matches = (list.json().data as Array<{ season_label: string }>).filter(
      (row) => row.season_label === 'idempotency-test-season',
    );
    expect(matches).toHaveLength(1);
  });

  it('a different Idempotency-Key creates a genuinely new row', async () => {
    if (!available) return;

    const payload = { season_label: 'idempotency-test-season-2', budget_amount: 300 };
    const headersA = { authorization: `Bearer ${farmer.accessToken}`, 'idempotency-key': randomUUID() };
    const headersB = { authorization: `Bearer ${farmer.accessToken}`, 'idempotency-key': randomUUID() };

    const first = await app.inject({ method: 'POST', url: '/season-budgets', headers: headersA, payload });
    const second = await app.inject({ method: 'POST', url: '/season-budgets', headers: headersB, payload });

    expect(first.json().id).not.toBe(second.json().id);
  });
});
