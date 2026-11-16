import type { SupabaseClient } from '@supabase/supabase-js';
import type { Notification, NotificationCreate } from '@agroedge/shared/types/notification.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = [
  'id',
  'owner_user',
  'notification_type',
  'title',
  'short_message',
  'status',
  'created_at',
] as const satisfies readonly (keyof Notification)[];
const _columnsComplete: AssertCovers<typeof columns, keyof Notification> = true;

const writableFields = [
  'notification_type',
  'title',
  'short_message',
  'status',
] as const satisfies readonly (keyof NotificationCreate)[];

export function buildNotificationHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  // PATCH reuses NotificationCreate in the spec (no dedicated
  // NotificationUpdate schema), so create/update share the same field list.
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'notifications',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
  }, byIdLimiter);

  return {
    listNotifications: handlers.list,
    createNotification: handlers.create,
    getNotification: handlers.get,
    updateNotification: handlers.update,
    deleteNotification: handlers.remove,
  };
}
