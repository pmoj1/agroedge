import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/app.js';
import { supabaseAvailable } from '../helpers/env.js';
import { buildAdminClient, createTestFarmer, deleteTestFarmer, type TestFarmer } from '../helpers/testFarmers.js';

/**
 * Contract coverage for every one of the 28 paths in openapi.yaml.
 *
 * The heavy lifting is done by fastify-openapi-glue itself: it validates
 * every response against the spec's schema before it leaves the process
 * (strict ajv), so a shape mismatch surfaces as a 500 from src/app.ts's
 * error handler, not a passing test with a silently wrong body. This suite
 * asserts the documented status codes and a handful of key fields on top
 * of that, and specifically checks for the *absence* of a 500 with a
 * message that explains why, so a contract drift fails loudly here instead
 * of only in production traffic.
 */

interface FlatCase {
  kind: 'flat';
  name: string;
  listPath: string;
  itemPath: (id: string) => string;
  createBody: Record<string, unknown>;
  updateBody: Record<string, unknown>;
}

interface NestedCase {
  kind: 'nested';
  name: string;
  parentListPath: string;
  parentCreateBody: Record<string, unknown>;
  listPath: (parentId: string) => string;
  itemPath: (parentId: string, id: string) => string;
  createBody: Record<string, unknown>;
  updateBody: Record<string, unknown>;
}

const cases: (FlatCase | NestedCase)[] = [
  {
    kind: 'flat',
    name: 'farm-profiles',
    listPath: '/farm-profiles',
    itemPath: (id) => `/farm-profiles/${id}`,
    createBody: { farm_name: 'Test Farm', farm_size: 2.5, country: 'Botswana' },
    updateBody: { farm_name: 'Updated Farm' },
  },
  {
    kind: 'flat',
    name: 'activities',
    listPath: '/activities',
    itemPath: (id) => `/activities/${id}`,
    createBody: { activity_type: 'planting', activity_date: '2026-01-15', crop: 'maize' },
    updateBody: { notes: 'updated note' },
  },
  {
    kind: 'flat',
    name: 'expenses',
    listPath: '/expenses',
    itemPath: (id) => `/expenses/${id}`,
    createBody: { amount: 100, expense_date: '2026-01-15', category: 'seed' },
    updateBody: { amount: 150 },
  },
  {
    kind: 'flat',
    name: 'income-records',
    listPath: '/income-records',
    itemPath: (id) => `/income-records/${id}`,
    createBody: { income_date: '2026-01-15', crop: 'maize', total_revenue: 500 },
    updateBody: { total_revenue: 600 },
  },
  {
    kind: 'flat',
    name: 'season-budgets',
    listPath: '/season-budgets',
    itemPath: (id) => `/season-budgets/${id}`,
    createBody: { season_label: '2026-summer', budget_amount: 1000 },
    updateBody: { budget_amount: 1200 },
  },
  {
    kind: 'flat',
    name: 'ai-crop-plans',
    listPath: '/ai-crop-plans',
    itemPath: (id) => `/ai-crop-plans/${id}`,
    createBody: { crop: 'maize', recommendation_text: 'plant early' },
    updateBody: { recommendation_text: 'updated recommendation' },
  },
  {
    kind: 'flat',
    name: 'ai-insights',
    listPath: '/ai-insights',
    itemPath: (id) => `/ai-insights/${id}`,
    createBody: { category: 'yield', insight_text: 'looking good' },
    updateBody: { insight_text: 'updated insight' },
  },
  {
    kind: 'flat',
    name: 'ai-messages',
    listPath: '/ai-messages',
    itemPath: (id) => `/ai-messages/${id}`,
    createBody: { sender: 'farmer', message_text: 'hello' },
    updateBody: { message_text: 'updated message' },
  },
  {
    kind: 'flat',
    name: 'communication-preferences',
    listPath: '/communication-preferences',
    itemPath: (id) => `/communication-preferences/${id}`,
    createBody: { email_enabled: true, sms_enabled: false, whatsapp_enabled: false, in_app_enabled: true },
    updateBody: { sms_enabled: true },
  },
  {
    kind: 'flat',
    name: 'notifications',
    listPath: '/notifications',
    itemPath: (id) => `/notifications/${id}`,
    createBody: { title: 'Test notification', status: 'pending' },
    updateBody: { status: 'sent' },
  },
  {
    kind: 'flat',
    name: 'reminders',
    listPath: '/reminders',
    itemPath: (id) => `/reminders/${id}`,
    createBody: { reminder_datetime: '2026-02-01T08:00:00Z', title: 'water crops' },
    updateBody: { title: 'updated title' },
  },
  {
    kind: 'flat',
    name: 'weekly-reports',
    listPath: '/weekly-reports',
    itemPath: (id) => `/weekly-reports/${id}`,
    createBody: { report_text: 'summary' },
    updateBody: { report_text: 'updated summary' },
  },
  {
    kind: 'nested',
    name: 'activities/{activityId}/files',
    parentListPath: '/activities',
    parentCreateBody: { activity_type: 'planting', activity_date: '2026-01-15' },
    listPath: (parentId) => `/activities/${parentId}/files`,
    itemPath: (parentId, id) => `/activities/${parentId}/files/${id}`,
    createBody: { storage_path: 'farmer/test/receipt.jpg', file_type: 'photo' },
    updateBody: { file_type: 'receipt' },
  },
  {
    kind: 'nested',
    name: 'notifications/{notificationId}/delivery-logs',
    parentListPath: '/notifications',
    parentCreateBody: { title: 'Delivery test', status: 'pending' },
    listPath: (parentId) => `/notifications/${parentId}/delivery-logs`,
    itemPath: (parentId, id) => `/notifications/${parentId}/delivery-logs/${id}`,
    createBody: { channel: 'sms', delivery_status: 'sent' },
    updateBody: { delivery_status: 'delivered' },
  },
];

let available = false;

beforeAll(async () => {
  available = await supabaseAvailable();
});

describe('contract: full CRUD lifecycle matches openapi.yaml for every path', () => {
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

  it.each(cases)('$name', async (testCase) => {
    if (!available) {
      console.warn('SUPABASE_URL not reachable -- skipping contract test. Run `supabase start` locally to execute this suite.');
      return;
    }

    const auth = { authorization: `Bearer ${farmer.accessToken}` };
    let listPath: string;
    let itemPath: (id: string) => string;

    if (testCase.kind === 'nested') {
      const parentRes = await app.inject({
        method: 'POST',
        url: testCase.parentListPath,
        headers: auth,
        payload: testCase.parentCreateBody,
      });
      expect(parentRes.statusCode, parentRes.body).toBe(201);
      const parentId = parentRes.json().id as string;
      listPath = testCase.listPath(parentId);
      itemPath = (id: string) => testCase.itemPath(parentId, id);
    } else {
      listPath = testCase.listPath;
      itemPath = testCase.itemPath;
    }

    // POST
    const createRes = await app.inject({ method: 'POST', url: listPath, headers: auth, payload: testCase.createBody });
    expect(createRes.statusCode, createRes.body).toBe(201);
    const created = createRes.json();
    expect(created.id).toBeTypeOf('string');

    // GET (list) -- created row must appear
    const listRes = await app.inject({ method: 'GET', url: listPath, headers: auth });
    expect(listRes.statusCode, listRes.body).toBe(200);
    const listBody = listRes.json();
    expect(listBody).toHaveProperty('data');
    expect(listBody).toHaveProperty('limit');
    expect(listBody).toHaveProperty('offset');
    expect(listBody).toHaveProperty('total');
    expect((listBody.data as Array<{ id: string }>).some((row) => row.id === created.id)).toBe(true);

    // GET (by id)
    const getRes = await app.inject({ method: 'GET', url: itemPath(created.id), headers: auth });
    expect(getRes.statusCode, getRes.body).toBe(200);
    expect(getRes.json().id).toBe(created.id);

    // PATCH
    const patchRes = await app.inject({
      method: 'PATCH',
      url: itemPath(created.id),
      headers: auth,
      payload: testCase.updateBody,
    });
    expect(patchRes.statusCode, patchRes.body).toBe(200);
    const updated = patchRes.json();
    for (const [key, value] of Object.entries(testCase.updateBody)) {
      expect(updated[key]).toBe(value);
    }

    // DELETE
    const deleteRes = await app.inject({ method: 'DELETE', url: itemPath(created.id), headers: auth });
    expect(deleteRes.statusCode, deleteRes.body).toBe(204);
    expect(deleteRes.body).toBe('');

    // GET after delete -- hard delete, not soft delete (db/CLAUDE.md)
    const afterDeleteRes = await app.inject({ method: 'GET', url: itemPath(created.id), headers: auth });
    expect(afterDeleteRes.statusCode, afterDeleteRes.body).toBe(404);
  });

  it('401 without a token', async () => {
    if (!available) return;
    const res = await app.inject({ method: 'GET', url: '/farm-profiles' });
    expect(res.statusCode).toBe(401);
  });
});
