// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum AiMessageSender {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('farmer')
  farmer('farmer'),
  @JsonValue('ai')
  ai('ai');

  final String? value;

  const AiMessageSender(this.value);
}

enum AiMessageCreateSender {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('farmer')
  farmer('farmer'),
  @JsonValue('ai')
  ai('ai');

  final String? value;

  const AiMessageCreateSender(this.value);
}

enum AiMessageUpdateSender {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('farmer')
  farmer('farmer'),
  @JsonValue('ai')
  ai('ai');

  final String? value;

  const AiMessageUpdateSender(this.value);
}

enum NotificationStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('pending')
  pending('pending'),
  @JsonValue('sent')
  sent('sent'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('read')
  read('read');

  final String? value;

  const NotificationStatus(this.value);
}

enum NotificationCreateStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('pending')
  pending('pending'),
  @JsonValue('sent')
  sent('sent'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('read')
  read('read');

  final String? value;

  const NotificationCreateStatus(this.value);
}

enum ReminderStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('scheduled')
  scheduled('scheduled'),
  @JsonValue('sent')
  sent('sent'),
  @JsonValue('dismissed')
  dismissed('dismissed'),
  @JsonValue('cancelled')
  cancelled('cancelled');

  final String? value;

  const ReminderStatus(this.value);
}

enum ReminderCreateStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('scheduled')
  scheduled('scheduled'),
  @JsonValue('sent')
  sent('sent'),
  @JsonValue('dismissed')
  dismissed('dismissed'),
  @JsonValue('cancelled')
  cancelled('cancelled');

  final String? value;

  const ReminderCreateStatus(this.value);
}

enum ReminderUpdateStatus {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('scheduled')
  scheduled('scheduled'),
  @JsonValue('sent')
  sent('sent'),
  @JsonValue('dismissed')
  dismissed('dismissed'),
  @JsonValue('cancelled')
  cancelled('cancelled');

  final String? value;

  const ReminderUpdateStatus(this.value);
}
