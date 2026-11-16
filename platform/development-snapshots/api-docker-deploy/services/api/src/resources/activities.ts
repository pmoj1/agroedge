import type { SupabaseClient } from '@supabase/supabase-js';
import type { Activity, ActivityCreate } from '@agroedge/shared/types/activity.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = [
  'id',
  'owner_user',
  'activity_type',
  'crop',
  'activity_date',
  'gps_lat',
  'gps_lng',
  'notes',
  'season_label',
  'yield_quantity',
  'yield_unit',
  'created_at',
  'updated_at',
] as const satisfies readonly (keyof Activity)[];
const _columnsComplete: AssertCovers<typeof columns, keyof Activity> = true;

const writableFields = [
  'activity_type',
  'crop',
  'activity_date',
  'gps_lat',
  'gps_lng',
  'notes',
  'season_label',
  'yield_quantity',
  'yield_unit',
] as const satisfies readonly (keyof ActivityCreate)[];

export function buildActivityHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'activities',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
    hasUpdatedAt: true,
  }, byIdLimiter);

  return {
    listActivities: handlers.list,
    createActivity: handlers.create,
    getActivity: handlers.get,
    updateActivity: handlers.update,
    deleteActivity: handlers.remove,
  };
}
