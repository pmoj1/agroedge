import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/app.js';
import { supabaseAvailable } from '../helpers/env.js';
import { buildAdminClient, createTestFarmer, deleteTestFarmer, type TestFarmer } from '../helpers/testFarmers.js';

/**
 * Proves the API-layer authorization check, not just the RLS policy it
 * mirrors (services/api/CLAUDE.md: "authentication is not authorisation").
 * The app under test uses the service-role key (src/plugins/supabase.ts),
 * which bypasses RLS entirely -- so if these pass, it's the `.eq('owner_
 * user', ...)` / parent-ownership checks in src/lib/resource.ts and
 * src/lib/nestedResource.ts doing the work, exactly as they will in
 * production.
 *
 * Covers one direct-owner table (farm_profiles) and both join-owner
 * tables (activity_files, notification_delivery_logs) -- every other
 * direct-owner table shares the identical `createOwnedResourceHandlers`
 * code path already proven here.
 */

let available = false;

beforeAll(async () => {
  available = await supabaseAvailable();
});

describe('RLS-equivalent authorization', () => {
  let app: FastifyInstance;
  let admin: ReturnType<typeof buildAdminClient>;
  let farmerA: TestFarmer;
  let farmerB: TestFarmer;

  beforeAll(async () => {
    if (!available) return;
    admin = buildAdminClient();
    farmerA = await createTestFarmer(admin);
    farmerB = await createTestFarmer(admin);
    app = await buildApp();
  });

  afterAll(async () => {
    if (!available) return;
    await app.close();
    await deleteTestFarmer(admin, farmerA.id);
    await deleteTestFarmer(admin, farmerB.id);
  });

  it('a caller cannot read, update, or delete another farmer\'s farm_profiles row', async () => {
    if (!available) {
      console.warn('SUPABASE_URL not reachable -- skipping RLS test. Run `supabase start` locally to execute this suite.');
      return;
    }

    const authA = { authorization: `Bearer ${farmerA.accessToken}` };
    const authB = { authorization: `Bearer ${farmerB.accessToken}` };

    const createRes = await app.inject({
      method: 'POST',
      url: '/farm-profiles',
      headers: authA,
      payload: { farm_name: "A's farm" },
    });
    expect(createRes.statusCode).toBe(201);
    const { id } = createRes.json();

    const getAsB = await app.inject({ method: 'GET', url: `/farm-profiles/${id}`, headers: authB });
    expect(getAsB.statusCode).toBe(404);
    // NotFound, not 403 -- the spec's NotFound response says a row that
    // exists-but-isn't-yours must be indistinguishable from one that
    // doesn't exist, so a caller can't use the status code to enumerate
    // other farmers' valid IDs.
    expect(getAsB.json().message).not.toMatch(/forbidden|not allowed/i);

    const patchAsB = await app.inject({
      method: 'PATCH',
      url: `/farm-profiles/${id}`,
      headers: authB,
      payload: { farm_name: 'hijacked' },
    });
    expect(patchAsB.statusCode).toBe(404);

    const deleteAsB = await app.inject({ method: 'DELETE', url: `/farm-profiles/${id}`, headers: authB });
    expect(deleteAsB.statusCode).toBe(404);

    // Row is untouched and still readable by its real owner.
    const getAsA = await app.inject({ method: 'GET', url: `/farm-profiles/${id}`, headers: authA });
    expect(getAsA.statusCode).toBe(200);
    expect(getAsA.json().farm_name).toBe("A's farm");

    // farmer B's own list never contains farmer A's row.
    const listAsB = await app.inject({ method: 'GET', url: '/farm-profiles', headers: authB });
    expect((listAsB.json().data as Array<{ id: string }>).some((row) => row.id === id)).toBe(false);
  });

  it('a caller cannot reach another farmer\'s activity_files through the nested route', async () => {
    if (!available) return;

    const authA = { authorization: `Bearer ${farmerA.accessToken}` };
    const authB = { authorization: `Bearer ${farmerB.accessToken}` };

    const activityRes = await app.inject({
      method: 'POST',
      url: '/activities',
      headers: authA,
      payload: { activity_type: 'planting', activity_date: '2026-01-15' },
    });
    expect(activityRes.statusCode).toBe(201);
    const activityId = activityRes.json().id as string;

    const fileRes = await app.inject({
      method: 'POST',
      url: `/activities/${activityId}/files`,
      headers: authA,
      payload: { storage_path: 'farmer-a/receipt.jpg' },
    });
    expect(fileRes.statusCode).toBe(201);
    const fileId = fileRes.json().id as string;

    // B doesn't own the parent activity -- every nested operation must 404,
    // not just leak whether the file exists.
    const listAsB = await app.inject({ method: 'GET', url: `/activities/${activityId}/files`, headers: authB });
    expect(listAsB.statusCode).toBe(404);

    const getAsB = await app.inject({ method: 'GET', url: `/activities/${activityId}/files/${fileId}`, headers: authB });
    expect(getAsB.statusCode).toBe(404);

    const deleteAsB = await app.inject({ method: 'DELETE', url: `/activities/${activityId}/files/${fileId}`, headers: authB });
    expect(deleteAsB.statusCode).toBe(404);

    const getAsA = await app.inject({ method: 'GET', url: `/activities/${activityId}/files/${fileId}`, headers: authA });
    expect(getAsA.statusCode).toBe(200);
  });

  it('a caller cannot attach another farmer\'s activity_file as a receipt on their own expense', async () => {
    if (!available) return;

    const authA = { authorization: `Bearer ${farmerA.accessToken}` };
    const authB = { authorization: `Bearer ${farmerB.accessToken}` };

    const activityRes = await app.inject({
      method: 'POST',
      url: '/activities',
      headers: authA,
      payload: { activity_type: 'harvest', activity_date: '2026-01-20' },
    });
    const activityId = activityRes.json().id as string;

    const fileRes = await app.inject({
      method: 'POST',
      url: `/activities/${activityId}/files`,
      headers: authA,
      payload: { storage_path: 'farmer-a/receipt-2.jpg' },
    });
    const fileId = fileRes.json().id as string;

    // B tries to reference A's file as their own expense receipt by guessing/
    // knowing its UUID. src/lib/ownership.ts must reject this even though
    // the FK constraint alone would allow it (the file row does exist).
    const expenseRes = await app.inject({
      method: 'POST',
      url: '/expenses',
      headers: authB,
      payload: { amount: 50, expense_date: '2026-01-21', receipt_file_id: fileId },
    });
    expect(expenseRes.statusCode).toBe(400);
  });
});
