import type { SupabaseClient } from '@supabase/supabase-js';
import type { WeeklyReport, WeeklyReportCreate } from '@agroedge/shared/types/weekly-report.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = ['id', 'owner_user', 'report_text', 'delivery_preference', 'created_at'] as const satisfies readonly (keyof WeeklyReport)[];
const _columnsComplete: AssertCovers<typeof columns, keyof WeeklyReport> = true;

const writableFields = ['report_text', 'delivery_preference'] as const satisfies readonly (keyof WeeklyReportCreate)[];

export function buildWeeklyReportHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  // PATCH reuses WeeklyReportCreate in the spec (no dedicated
  // WeeklyReportUpdate schema), so create/update share the same field list.
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'weekly_reports',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
  }, byIdLimiter);

  return {
    listWeeklyReports: handlers.list,
    createWeeklyReport: handlers.create,
    getWeeklyReport: handlers.get,
    updateWeeklyReport: handlers.update,
    deleteWeeklyReport: handlers.remove,
  };
}
