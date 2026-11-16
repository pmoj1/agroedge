import type { SupabaseClient } from '@supabase/supabase-js';
import type {
  CommunicationPreference,
  CommunicationPreferenceCreate,
} from '@agroedge/shared/types/communication-preference.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = [
  'id',
  'owner_user',
  'default_channel',
  'notification_type',
  'email_enabled',
  'sms_enabled',
  'whatsapp_enabled',
  'in_app_enabled',
  'updated_at',
] as const satisfies readonly (keyof CommunicationPreference)[];
const _columnsComplete: AssertCovers<typeof columns, keyof CommunicationPreference> = true;

const writableFields = [
  'default_channel',
  'notification_type',
  'email_enabled',
  'sms_enabled',
  'whatsapp_enabled',
  'in_app_enabled',
] as const satisfies readonly (keyof CommunicationPreferenceCreate)[];

export function buildCommunicationPreferenceHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'communication_preferences',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
    // No created_at column on this table -- list ordering falls back to
    // updated_at, which is fine since owner_user is unique (at most one row).
    orderColumn: 'updated_at',
    hasUpdatedAt: true,
    uniqueViolationMessage: 'Communication preferences already exist for this user; use PATCH to update them.',
  }, byIdLimiter);

  return {
    listCommunicationPreferences: handlers.list,
    createCommunicationPreference: handlers.create,
    getCommunicationPreference: handlers.get,
    updateCommunicationPreference: handlers.update,
    deleteCommunicationPreference: handlers.remove,
  };
}
