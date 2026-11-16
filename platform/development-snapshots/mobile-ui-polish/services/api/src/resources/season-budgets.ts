import type { SupabaseClient } from '@supabase/supabase-js';
import type { SeasonBudget, SeasonBudgetCreate } from '@agroedge/shared/types/season-budget.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = [
  'id',
  'owner_user',
  'season_label',
  'category',
  'budget_amount',
  'created_at',
  'updated_at',
] as const satisfies readonly (keyof SeasonBudget)[];
const _columnsComplete: AssertCovers<typeof columns, keyof SeasonBudget> = true;

const writableFields = ['season_label', 'category', 'budget_amount'] as const satisfies readonly (keyof SeasonBudgetCreate)[];

export function buildSeasonBudgetHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'season_budgets',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
    hasUpdatedAt: true,
  }, byIdLimiter);

  return {
    listSeasonBudgets: handlers.list,
    createSeasonBudget: handlers.create,
    getSeasonBudget: handlers.get,
    updateSeasonBudget: handlers.update,
    deleteSeasonBudget: handlers.remove,
  };
}
