#!/usr/bin/env node
// Splits the openapi-typescript output (types/schema.ts) into one file per
// resource, per packages/shared/CLAUDE.md ("one file per resource").
//
// This script does not define any field, type, or optionality -- all of
// that comes from types/schema.ts, which openapi-typescript generates
// straight from openapi/openapi.yaml. This script only maps each resource
// to the schema component names the spec already gives it. If a name below
// stops matching the spec, the generated re-export fails to type-check --
// that's the drift check.
//
// Regenerate via: npm run generate:types

import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const typesDir = join(__dirname, '..', 'types');

// [fileBaseName, BaseSchema, CreateSchema, UpdateSchema, ListResponseSchema]
// UpdateSchema repeats CreateSchema for resources whose OpenAPI spec has no
// distinct Update schema (their PATCH operation reuses the Create body).
const resources = [
  ['farm-profile', 'FarmProfile', 'FarmProfileCreate', 'FarmProfileCreate', 'FarmProfileListResponse'],
  ['activity', 'Activity', 'ActivityCreate', 'ActivityUpdate', 'ActivityListResponse'],
  ['activity-file', 'ActivityFile', 'ActivityFileCreate', 'ActivityFileUpdate', 'ActivityFileListResponse'],
  ['expense', 'Expense', 'ExpenseCreate', 'ExpenseUpdate', 'ExpenseListResponse'],
  ['income-record', 'IncomeRecord', 'IncomeRecordCreate', 'IncomeRecordUpdate', 'IncomeRecordListResponse'],
  ['season-budget', 'SeasonBudget', 'SeasonBudgetCreate', 'SeasonBudgetUpdate', 'SeasonBudgetListResponse'],
  ['ai-crop-plan', 'AiCropPlan', 'AiCropPlanCreate', 'AiCropPlanCreate', 'AiCropPlanListResponse'],
  ['ai-insight', 'AiInsight', 'AiInsightCreate', 'AiInsightCreate', 'AiInsightListResponse'],
  ['ai-message', 'AiMessage', 'AiMessageCreate', 'AiMessageUpdate', 'AiMessageListResponse'],
  ['communication-preference', 'CommunicationPreference', 'CommunicationPreferenceCreate', 'CommunicationPreferenceCreate', 'CommunicationPreferenceListResponse'],
  ['notification', 'Notification', 'NotificationCreate', 'NotificationCreate', 'NotificationListResponse'],
  ['notification-delivery-log', 'NotificationDeliveryLog', 'NotificationDeliveryLogCreate', 'NotificationDeliveryLogUpdate', 'NotificationDeliveryLogListResponse'],
  ['reminder', 'Reminder', 'ReminderCreate', 'ReminderUpdate', 'ReminderListResponse'],
  ['weekly-report', 'WeeklyReport', 'WeeklyReportCreate', 'WeeklyReportCreate', 'WeeklyReportListResponse'],
];

for (const [file, base, create, update, list] of resources) {
  const contents = `// GENERATED FILE -- do not hand-edit.
// Source: packages/shared/openapi/openapi.yaml
// Regenerate via: npm run generate:types (packages/shared)

import type { components } from './schema.js';

export type ${base} = components['schemas']['${base}'];
export type ${base}Create = components['schemas']['${create}'];
export type ${base}Update = components['schemas']['${update}'];
export type ${base}ListResponse = components['schemas']['${list}'];
`;
  writeFileSync(join(typesDir, `${file}.ts`), contents);
}

console.log(`Wrote ${resources.length} resource type files to ${typesDir}`);
