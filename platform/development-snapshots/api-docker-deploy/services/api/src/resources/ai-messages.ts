import type { SupabaseClient } from '@supabase/supabase-js';
import type { AiMessage, AiMessageCreate } from '@agroedge/shared/types/ai-message.js';
import type { FixedWindowLimiter } from '../lib/rateLimiter.js';
import type { AssertCovers } from '../lib/typeCheck.js';
import { createOwnedResourceHandlers } from '../lib/resource.js';

const columns = ['id', 'owner_user', 'sender', 'message_text', 'created_at'] as const satisfies readonly (keyof AiMessage)[];
const _columnsComplete: AssertCovers<typeof columns, keyof AiMessage> = true;

const writableFields = ['sender', 'message_text'] as const satisfies readonly (keyof AiMessageCreate)[];

export function buildAiMessageHandlers(supabase: SupabaseClient, byIdLimiter: FixedWindowLimiter) {
  const handlers = createOwnedResourceHandlers(supabase, {
    table: 'ai_messages',
    columns,
    createFields: writableFields,
    updateFields: writableFields,
  }, byIdLimiter);

  return {
    listAiMessages: handlers.list,
    createAiMessage: handlers.create,
    getAiMessage: handlers.get,
    updateAiMessage: handlers.update,
    deleteAiMessage: handlers.remove,
  };
}
