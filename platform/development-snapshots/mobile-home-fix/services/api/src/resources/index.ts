import type { SupabaseClient } from '@supabase/supabase-js';
import { FixedWindowLimiter } from '../lib/rateLimiter.js';
import { buildFarmProfileHandlers } from './farm-profiles.js';
import { buildActivityHandlers } from './activities.js';
import { buildActivityFileHandlers } from './activity-files.js';
import { buildExpenseHandlers } from './expenses.js';
import { buildIncomeRecordHandlers } from './income-records.js';
import { buildSeasonBudgetHandlers } from './season-budgets.js';
import { buildAiCropPlanHandlers } from './ai-crop-plans.js';
import { buildAiInsightHandlers } from './ai-insights.js';
import { buildAiMessageHandlers } from './ai-messages.js';
import { buildCommunicationPreferenceHandlers } from './communication-preferences.js';
import { buildNotificationHandlers } from './notifications.js';
import { buildNotificationDeliveryLogHandlers } from './notification-delivery-logs.js';
import { buildReminderHandlers } from './reminders.js';
import { buildWeeklyReportHandlers } from './weekly-reports.js';

/**
 * One object, keyed by operationId, handed to fastify-openapi-glue as
 * `serviceHandlers`. The plugin maps every operation in openapi.yaml to the
 * method of the same name here; a missing key means a 500 at request time
 * ("Operation <id> not implemented"), so this list is the single place to
 * check for full spec coverage.
 */
export interface StrictRateLimitConfig {
  max: number;
  windowMs: number;
}

export function buildServiceHandlers(supabase: SupabaseClient, strictRateLimit: StrictRateLimitConfig) {
  // One counter, shared by every single-resource-by-id operation (get/
  // update/delete) across all 14 resources, keyed by authenticated user.
  // This is the "tighter limit on anything that could be used to
  // enumerate farmer records" (services/api/CLAUDE.md) -- a single bound
  // on ID-guessing across the whole API, not 14 separate ones.
  const byIdLimiter = new FixedWindowLimiter(strictRateLimit.max, strictRateLimit.windowMs);

  return {
    ...buildFarmProfileHandlers(supabase, byIdLimiter),
    ...buildActivityHandlers(supabase, byIdLimiter),
    ...buildActivityFileHandlers(supabase, byIdLimiter),
    ...buildExpenseHandlers(supabase, byIdLimiter),
    ...buildIncomeRecordHandlers(supabase, byIdLimiter),
    ...buildSeasonBudgetHandlers(supabase, byIdLimiter),
    ...buildAiCropPlanHandlers(supabase, byIdLimiter),
    ...buildAiInsightHandlers(supabase, byIdLimiter),
    ...buildAiMessageHandlers(supabase, byIdLimiter),
    ...buildCommunicationPreferenceHandlers(supabase, byIdLimiter),
    ...buildNotificationHandlers(supabase, byIdLimiter),
    ...buildNotificationDeliveryLogHandlers(supabase, byIdLimiter),
    ...buildReminderHandlers(supabase, byIdLimiter),
    ...buildWeeklyReportHandlers(supabase, byIdLimiter),
  };
}
