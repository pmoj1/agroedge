import type { SupabaseClient } from '@supabase/supabase-js';
import type {
  NotificationDeliveryLog,
  NotificationDeliveryLogCreate,
} from '@agroedge/shared/types/notification-delivery-log.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createNestedResourceHandlers } from '../lib/nestedResource.js';

const columns = [
  'id',
  'notification_id',
  'channel',
  'delivery_status',
  'delivered_at',
  'created_at',
] as const satisfies readonly (keyof NotificationDeliveryLog)[];
const _columnsComplete: AssertCovers<typeof columns, keyof NotificationDeliveryLog> = true;

const writableFields = [
  'channel',
  'delivery_status',
  'delivered_at',
] as const satisfies readonly (keyof NotificationDeliveryLogCreate)[];

export function buildNotificationDeliveryLogHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createNestedResourceHandlers(supabase, {
    table: 'notification_delivery_logs',
    parentTable: 'notifications',
    parentIdParam: 'notificationId',
    foreignKey: 'notification_id',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
  }, byIdLimiter);

  return {
    listNotificationDeliveryLogs: handlers.list,
    createNotificationDeliveryLog: handlers.create,
    getNotificationDeliveryLog: handlers.get,
    updateNotificationDeliveryLog: handlers.update,
    deleteNotificationDeliveryLog: handlers.remove,
  };
}
