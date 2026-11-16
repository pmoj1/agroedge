import type { SupabaseClient } from '@supabase/supabase-js';
import type { AiCropPlan, AiCropPlanCreate } from '@agroedge/shared/types/ai-crop-plan.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = [
  'id',
  'owner_user',
  'crop',
  'priority_action',
  'recommendation_text',
  'created_at',
] as const satisfies readonly (keyof AiCropPlan)[];
const _columnsComplete: AssertCovers<typeof columns, keyof AiCropPlan> = true;

const writableFields = ['crop', 'priority_action', 'recommendation_text'] as const satisfies readonly (keyof AiCropPlanCreate)[];

export function buildAiCropPlanHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  // PATCH reuses AiCropPlanCreate in the spec (no dedicated AiCropPlanUpdate
  // schema), so create/update share the same field list here too.
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'ai_crop_plans',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
  }, byIdLimiter);

  return {
    listAiCropPlans: handlers.list,
    createAiCropPlan: handlers.create,
    getAiCropPlan: handlers.get,
    updateAiCropPlan: handlers.update,
    deleteAiCropPlan: handlers.remove,
  };
}
