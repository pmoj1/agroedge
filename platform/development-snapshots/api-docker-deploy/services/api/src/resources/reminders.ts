import type { SupabaseClient } from '@supabase/supabase-js';
import type { Reminder, ReminderCreate } from '@agroedge/shared/types/reminder.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';
import { assertOwnsActivity } from '../lib/ownership.js';

const columns = [
  'id',
  'owner_user',
  'related_activity_id',
  'related_crop',
  'title',
  'reminder_datetime',
  'delivery_channel',
  'status',
  'created_at',
] as const satisfies readonly (keyof Reminder)[];
const _columnsComplete: AssertCovers<typeof columns, keyof Reminder> = true;

const writableFields = [
  'related_activity_id',
  'related_crop',
  'title',
  'reminder_datetime',
  'delivery_channel',
  'status',
] as const satisfies readonly (keyof ReminderCreate)[];

export function buildReminderHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'reminders',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
    onBeforeWrite: async (client, ownerUser, fields) => {
      const relatedActivityId = fields.related_activity_id;
      if (typeof relatedActivityId === 'string') {
        await assertOwnsActivity(client, ownerUser, relatedActivityId);
      }
    },
  }, byIdLimiter);

  return {
    listReminders: handlers.list,
    createReminder: handlers.create,
    getReminder: handlers.get,
    updateReminder: handlers.update,
    deleteReminder: handlers.remove,
  };
}
