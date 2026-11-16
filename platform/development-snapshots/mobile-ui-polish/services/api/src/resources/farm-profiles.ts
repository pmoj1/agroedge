import type { SupabaseClient } from '@supabase/supabase-js';
import type { FarmProfile, FarmProfileCreate } from '@agroedge/shared/types/farm-profile.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = [
  'id',
  'owner_user',
  'farm_name',
  'farm_size',
  'farm_type',
  'country',
  'region',
  'gps_lat',
  'gps_lng',
  'primary_crop',
  'secondary_crop',
  'created_at',
  'updated_at',
] as const satisfies readonly (keyof FarmProfile)[];
const _columnsComplete: AssertCovers<typeof columns, keyof FarmProfile> = true;

const writableFields = [
  'farm_name',
  'farm_size',
  'farm_type',
  'country',
  'region',
  'gps_lat',
  'gps_lng',
  'primary_crop',
  'secondary_crop',
] as const satisfies readonly (keyof FarmProfileCreate)[];

export function buildFarmProfileHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'farm_profiles',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
    hasUpdatedAt: true,
  }, byIdLimiter);

  return {
    listFarmProfiles: handlers.list,
    createFarmProfile: handlers.create,
    getFarmProfile: handlers.get,
    updateFarmProfile: handlers.update,
    deleteFarmProfile: handlers.remove,
  };
}
