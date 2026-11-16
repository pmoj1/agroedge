import type { SupabaseClient } from '@supabase/supabase-js';
import { BadRequestError } from './errors.js';

/**
 * A few Create/Update payloads carry a foreign key into another farmer-
 * owned table (Expense.receipt_file_id, IncomeRecord.document_file_id ->
 * activity_files; Reminder.related_activity_id -> activities). The
 * Postgres FK constraint only proves the row exists, not that it belongs
 * to the caller -- a farmer could otherwise attach another farmer's
 * receipt file to their own expense just by guessing its UUID. This is
 * exactly the "authentication is not authorisation" case CLAUDE.md calls
 * out, applied to a nested reference instead of the resource itself.
 *
 * Only called when the field is present in the request body; all of these
 * columns are nullable.
 */

export async function assertOwnsActivity(
  supabase: SupabaseClient,
  ownerUser: string,
  activityId: string,
): Promise<void> {
  const { data } = await supabase
    .from('activities')
    .select('id')
    .eq('id', activityId)
    .eq('owner_user', ownerUser)
    .maybeSingle();

  if (!data) {
    throw new BadRequestError('related_activity_id does not reference an activity you own.', 'invalid_reference');
  }
}

export async function assertOwnsActivityFile(
  supabase: SupabaseClient,
  ownerUser: string,
  fileId: string,
  field: string,
): Promise<void> {
  const { data } = await supabase
    .from('activity_files')
    .select('id, activities!inner(owner_user)')
    .eq('id', fileId)
    .eq('activities.owner_user', ownerUser)
    .maybeSingle();

  if (!data) {
    throw new BadRequestError(`${field} does not reference a file attached to an activity you own.`, 'invalid_reference');
  }
}
