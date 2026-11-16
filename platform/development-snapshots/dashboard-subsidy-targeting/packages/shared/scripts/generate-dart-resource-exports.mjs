#!/usr/bin/env node
// Splits the swagger_dart_code_generator output (lib/models/_generated/) into
// one file per resource, per packages/shared/CLAUDE.md ("one file per resource")
// and to mirror types/*.ts on the TypeScript side.
//
// This script does not define any field, type, or optionality -- all of that
// comes from lib/models/_generated/openapi.models.swagger.dart (and its
// .enums.swagger.dart / .swagger.g.dart siblings), which swagger_dart_code_generator
// generates straight from openapi/openapi.yaml via `dart run build_runner build`.
// Each output file below is a plain `export` (Dart's re-export directive), so
// fromJson/toJson and every field come from the generated class unchanged --
// this script only picks which class names belong to which resource file. If
// a name below stops matching the generated output, the export fails to
// resolve -- that's the drift check.
//
// Regenerate via: npm run generate:models (packages/shared)

import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const modelsDir = join(__dirname, '..', 'lib', 'models');

// [fileBaseName, BaseClass, CreateClass, UpdateClass, ListResponseClass, enumNames[]]
// UpdateClass repeats CreateClass for resources whose OpenAPI spec has no
// distinct Update schema (their PATCH operation reuses the Create body) --
// swagger_dart_code_generator then has no separate ...Update class either.
const resources = [
  ['farm-profile', 'FarmProfile', 'FarmProfileCreate', 'FarmProfileCreate', 'FarmProfileListResponse', []],
  ['activity', 'Activity', 'ActivityCreate', 'ActivityUpdate', 'ActivityListResponse', []],
  ['activity-file', 'ActivityFile', 'ActivityFileCreate', 'ActivityFileUpdate', 'ActivityFileListResponse', []],
  ['expense', 'Expense', 'ExpenseCreate', 'ExpenseUpdate', 'ExpenseListResponse', []],
  ['income-record', 'IncomeRecord', 'IncomeRecordCreate', 'IncomeRecordUpdate', 'IncomeRecordListResponse', []],
  ['season-budget', 'SeasonBudget', 'SeasonBudgetCreate', 'SeasonBudgetUpdate', 'SeasonBudgetListResponse', []],
  ['ai-crop-plan', 'AiCropPlan', 'AiCropPlanCreate', 'AiCropPlanCreate', 'AiCropPlanListResponse', []],
  ['ai-insight', 'AiInsight', 'AiInsightCreate', 'AiInsightCreate', 'AiInsightListResponse', []],
  ['ai-message', 'AiMessage', 'AiMessageCreate', 'AiMessageUpdate', 'AiMessageListResponse', ['AiMessageSender', 'AiMessageCreateSender', 'AiMessageUpdateSender']],
  ['communication-preference', 'CommunicationPreference', 'CommunicationPreferenceCreate', 'CommunicationPreferenceCreate', 'CommunicationPreferenceListResponse', []],
  ['notification', 'Notification', 'NotificationCreate', 'NotificationCreate', 'NotificationListResponse', ['NotificationStatus', 'NotificationCreateStatus']],
  ['notification-delivery-log', 'NotificationDeliveryLog', 'NotificationDeliveryLogCreate', 'NotificationDeliveryLogUpdate', 'NotificationDeliveryLogListResponse', []],
  ['reminder', 'Reminder', 'ReminderCreate', 'ReminderUpdate', 'ReminderListResponse', ['ReminderStatus', 'ReminderCreateStatus', 'ReminderUpdateStatus']],
  ['weekly-report', 'WeeklyReport', 'WeeklyReportCreate', 'WeeklyReportCreate', 'WeeklyReportListResponse', []],
];

for (const [file, base, create, update, list, enums] of resources) {
  const classNames = [...new Set([base, create, update, list])];
  const lines = [
    '// GENERATED FILE -- do not hand-edit.',
    '// Source: packages/shared/openapi/openapi.yaml',
    '// Regenerate via: npm run generate:models (packages/shared)',
    '',
    `export '_generated/openapi.models.swagger.dart'`,
    `    show ${classNames.join(', ')};`,
  ];
  if (enums.length > 0) {
    lines.push(
      `export '_generated/openapi.enums.swagger.dart'`,
      `    show ${enums.join(', ')};`,
    );
  }
  lines.push('');
  writeFileSync(join(modelsDir, `${file}.dart`), lines.join('\n'));
}

console.log(`Wrote ${resources.length} resource model files to ${modelsDir}`);
