import type { SupabaseClient } from '@supabase/supabase-js';
import type { IncomeRecord, IncomeRecordCreate } from '@agroedge/shared/types/income-record.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';
import { assertOwnsActivityFile } from '../lib/ownership.js';

const columns = [
  'id',
  'owner_user',
  'crop',
  'buyer',
  'income_date',
  'price_per_unit',
  'quantity_sold',
  'total_revenue',
  'season_label',
  'document_file_id',
  'created_at',
  'updated_at',
] as const satisfies readonly (keyof IncomeRecord)[];
const _columnsComplete: AssertCovers<typeof columns, keyof IncomeRecord> = true;

const writableFields = [
  'crop',
  'buyer',
  'income_date',
  'price_per_unit',
  'quantity_sold',
  'total_revenue',
  'season_label',
  'document_file_id',
] as const satisfies readonly (keyof IncomeRecordCreate)[];

export function buildIncomeRecordHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'income_records',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
    hasUpdatedAt: true,
    onBeforeWrite: async (client, ownerUser, fields) => {
      const documentFileId = fields.document_file_id;
      if (typeof documentFileId === 'string') {
        await assertOwnsActivityFile(client, ownerUser, documentFileId, 'document_file_id');
      }
    },
  }, byIdLimiter);

  return {
    listIncomeRecords: handlers.list,
    createIncomeRecord: handlers.create,
    getIncomeRecord: handlers.get,
    updateIncomeRecord: handlers.update,
    deleteIncomeRecord: handlers.remove,
  };
}
