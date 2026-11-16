import type { SupabaseClient } from '@supabase/supabase-js';
import type { ActivityFile, ActivityFileCreate } from '@agroedge/shared/types/activity-file.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createNestedResourceHandlers } from '../lib/nestedResource.js';

const columns = ['id', 'activity_id', 'storage_path', 'file_type', 'created_at'] as const satisfies readonly (keyof ActivityFile)[];
const _columnsComplete: AssertCovers<typeof columns, keyof ActivityFile> = true;

const writableFields = ['storage_path', 'file_type'] as const satisfies readonly (keyof ActivityFileCreate)[];

export function buildActivityFileHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createNestedResourceHandlers(supabase, {
    table: 'activity_files',
    parentTable: 'activities',
    parentIdParam: 'activityId',
    foreignKey: 'activity_id',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
  }, byIdLimiter);

  return {
    listActivityFiles: handlers.list,
    createActivityFile: handlers.create,
    getActivityFile: handlers.get,
    updateActivityFile: handlers.update,
    deleteActivityFile: handlers.remove,
  };
}
