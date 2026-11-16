import type { SupabaseClient } from '@supabase/supabase-js';
import type { AiInsight, AiInsightCreate } from '@agroedge/shared/types/ai-insight.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = ['id', 'owner_user', 'category', 'insight_text', 'created_at'] as const satisfies readonly (keyof AiInsight)[];
const _columnsComplete: AssertCovers<typeof columns, keyof AiInsight> = true;

const writableFields = ['category', 'insight_text'] as const satisfies readonly (keyof AiInsightCreate)[];

export function buildAiInsightHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  // PATCH reuses AiInsightCreate in the spec (no dedicated AiInsightUpdate
  // schema), so create/update share the same field list here too.
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'ai_insights',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
  }, byIdLimiter);

  return {
    listAiInsights: handlers.list,
    createAiInsight: handlers.create,
    getAiInsight: handlers.get,
    updateAiInsight: handlers.update,
    deleteAiInsight: handlers.remove,
  };
}
