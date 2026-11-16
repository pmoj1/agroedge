import type { SupabaseClient } from '@supabase/supabase-js';
import type { Expense, ExpenseCreate } from '@agroedge/shared/types/expense.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';
import { assertOwnsActivityFile } from '../lib/ownership.js';

const columns = [
  'id',
  'owner_user',
  'amount',
  'category',
  'expense_date',
  'notes',
  'season_label',
  'receipt_file_id',
  'created_at',
  'updated_at',
] as const satisfies readonly (keyof Expense)[];
const _columnsComplete: AssertCovers<typeof columns, keyof Expense> = true;

const writableFields = [
  'amount',
  'category',
  'expense_date',
  'notes',
  'season_label',
  'receipt_file_id',
] as const satisfies readonly (keyof ExpenseCreate)[];

export function buildExpenseHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'expenses',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
    hasUpdatedAt: true,
    onBeforeWrite: async (client, ownerUser, fields) => {
      const receiptFileId = fields.receipt_file_id;
      if (typeof receiptFileId === 'string') {
        await assertOwnsActivityFile(client, ownerUser, receiptFileId, 'receipt_file_id');
      }
    },
  }, byIdLimiter);

  return {
    listExpenses: handlers.list,
    createExpense: handlers.create,
    getExpense: handlers.get,
    updateExpense: handlers.update,
    deleteExpense: handlers.remove,
  };
}
