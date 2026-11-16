// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openapi.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) =>
    ApiError(message: json['message'] as String, code: json['code'] as String?);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
};

FarmProfile _$FarmProfileFromJson(Map<String, dynamic> json) => FarmProfile(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  farmName: json['farm_name'] as String?,
  farmSize: (json['farm_size'] as num?)?.toDouble(),
  farmType: json['farm_type'] as String?,
  country: json['country'] as String?,
  region: json['region'] as String?,
  gpsLat: (json['gps_lat'] as num?)?.toDouble(),
  gpsLng: (json['gps_lng'] as num?)?.toDouble(),
  primaryCrop: json['primary_crop'] as String?,
  secondaryCrop: json['secondary_crop'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FarmProfileToJson(FarmProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_user': instance.ownerUser,
      'farm_name': instance.farmName,
      'farm_size': instance.farmSize,
      'farm_type': instance.farmType,
      'country': instance.country,
      'region': instance.region,
      'gps_lat': instance.gpsLat,
      'gps_lng': instance.gpsLng,
      'primary_crop': instance.primaryCrop,
      'secondary_crop': instance.secondaryCrop,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

FarmProfileCreate _$FarmProfileCreateFromJson(Map<String, dynamic> json) =>
    FarmProfileCreate(
      farmName: json['farm_name'] as String?,
      farmSize: (json['farm_size'] as num?)?.toDouble(),
      farmType: json['farm_type'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      gpsLat: (json['gps_lat'] as num?)?.toDouble(),
      gpsLng: (json['gps_lng'] as num?)?.toDouble(),
      primaryCrop: json['primary_crop'] as String?,
      secondaryCrop: json['secondary_crop'] as String?,
    );

Map<String, dynamic> _$FarmProfileCreateToJson(FarmProfileCreate instance) =>
    <String, dynamic>{
      'farm_name': instance.farmName,
      'farm_size': instance.farmSize,
      'farm_type': instance.farmType,
      'country': instance.country,
      'region': instance.region,
      'gps_lat': instance.gpsLat,
      'gps_lng': instance.gpsLng,
      'primary_crop': instance.primaryCrop,
      'secondary_crop': instance.secondaryCrop,
    };

FarmProfileListResponse _$FarmProfileListResponseFromJson(
  Map<String, dynamic> json,
) => FarmProfileListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => FarmProfile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$FarmProfileListResponseToJson(
  FarmProfileListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  activityType: json['activity_type'] as String,
  crop: json['crop'] as String?,
  activityDate: DateTime.parse(json['activity_date'] as String),
  gpsLat: (json['gps_lat'] as num?)?.toDouble(),
  gpsLng: (json['gps_lng'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  seasonLabel: json['season_label'] as String?,
  yieldQuantity: (json['yield_quantity'] as num?)?.toDouble(),
  yieldUnit: json['yield_unit'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'owner_user': instance.ownerUser,
  'activity_type': instance.activityType,
  'crop': instance.crop,
  'activity_date': _dateToJson(instance.activityDate),
  'gps_lat': instance.gpsLat,
  'gps_lng': instance.gpsLng,
  'notes': instance.notes,
  'season_label': instance.seasonLabel,
  'yield_quantity': instance.yieldQuantity,
  'yield_unit': instance.yieldUnit,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

ActivityCreate _$ActivityCreateFromJson(Map<String, dynamic> json) =>
    ActivityCreate(
      activityType: json['activity_type'] as String,
      crop: json['crop'] as String?,
      activityDate: DateTime.parse(json['activity_date'] as String),
      gpsLat: (json['gps_lat'] as num?)?.toDouble(),
      gpsLng: (json['gps_lng'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      seasonLabel: json['season_label'] as String?,
      yieldQuantity: (json['yield_quantity'] as num?)?.toDouble(),
      yieldUnit: json['yield_unit'] as String?,
    );

Map<String, dynamic> _$ActivityCreateToJson(ActivityCreate instance) =>
    <String, dynamic>{
      'activity_type': instance.activityType,
      'crop': instance.crop,
      'activity_date': _dateToJson(instance.activityDate),
      'gps_lat': instance.gpsLat,
      'gps_lng': instance.gpsLng,
      'notes': instance.notes,
      'season_label': instance.seasonLabel,
      'yield_quantity': instance.yieldQuantity,
      'yield_unit': instance.yieldUnit,
    };

ActivityUpdate _$ActivityUpdateFromJson(Map<String, dynamic> json) =>
    ActivityUpdate(
      activityType: json['activity_type'] as String?,
      crop: json['crop'] as String?,
      activityDate: json['activity_date'] == null
          ? null
          : DateTime.parse(json['activity_date'] as String),
      gpsLat: (json['gps_lat'] as num?)?.toDouble(),
      gpsLng: (json['gps_lng'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      seasonLabel: json['season_label'] as String?,
      yieldQuantity: (json['yield_quantity'] as num?)?.toDouble(),
      yieldUnit: json['yield_unit'] as String?,
    );

Map<String, dynamic> _$ActivityUpdateToJson(ActivityUpdate instance) =>
    <String, dynamic>{
      'activity_type': instance.activityType,
      'crop': instance.crop,
      'activity_date': _dateToJson(instance.activityDate),
      'gps_lat': instance.gpsLat,
      'gps_lng': instance.gpsLng,
      'notes': instance.notes,
      'season_label': instance.seasonLabel,
      'yield_quantity': instance.yieldQuantity,
      'yield_unit': instance.yieldUnit,
    };

ActivityListResponse _$ActivityListResponseFromJson(
  Map<String, dynamic> json,
) => ActivityListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$ActivityListResponseToJson(
  ActivityListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

ActivityFile _$ActivityFileFromJson(Map<String, dynamic> json) => ActivityFile(
  id: json['id'] as String?,
  activityId: json['activity_id'] as String?,
  storagePath: json['storage_path'] as String,
  fileType: json['file_type'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ActivityFileToJson(ActivityFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activity_id': instance.activityId,
      'storage_path': instance.storagePath,
      'file_type': instance.fileType,
      'created_at': instance.createdAt?.toIso8601String(),
    };

ActivityFileCreate _$ActivityFileCreateFromJson(Map<String, dynamic> json) =>
    ActivityFileCreate(
      storagePath: json['storage_path'] as String,
      fileType: json['file_type'] as String?,
    );

Map<String, dynamic> _$ActivityFileCreateToJson(ActivityFileCreate instance) =>
    <String, dynamic>{
      'storage_path': instance.storagePath,
      'file_type': instance.fileType,
    };

ActivityFileUpdate _$ActivityFileUpdateFromJson(Map<String, dynamic> json) =>
    ActivityFileUpdate(
      storagePath: json['storage_path'] as String?,
      fileType: json['file_type'] as String?,
    );

Map<String, dynamic> _$ActivityFileUpdateToJson(ActivityFileUpdate instance) =>
    <String, dynamic>{
      'storage_path': instance.storagePath,
      'file_type': instance.fileType,
    };

ActivityFileListResponse _$ActivityFileListResponseFromJson(
  Map<String, dynamic> json,
) => ActivityFileListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => ActivityFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$ActivityFileListResponseToJson(
  ActivityFileListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String?,
  expenseDate: DateTime.parse(json['expense_date'] as String),
  notes: json['notes'] as String?,
  seasonLabel: json['season_label'] as String?,
  receiptFileId: json['receipt_file_id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'owner_user': instance.ownerUser,
  'amount': instance.amount,
  'category': instance.category,
  'expense_date': _dateToJson(instance.expenseDate),
  'notes': instance.notes,
  'season_label': instance.seasonLabel,
  'receipt_file_id': instance.receiptFileId,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

ExpenseCreate _$ExpenseCreateFromJson(Map<String, dynamic> json) =>
    ExpenseCreate(
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String?,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      notes: json['notes'] as String?,
      seasonLabel: json['season_label'] as String?,
      receiptFileId: json['receipt_file_id'] as String?,
    );

Map<String, dynamic> _$ExpenseCreateToJson(ExpenseCreate instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'category': instance.category,
      'expense_date': _dateToJson(instance.expenseDate),
      'notes': instance.notes,
      'season_label': instance.seasonLabel,
      'receipt_file_id': instance.receiptFileId,
    };

ExpenseUpdate _$ExpenseUpdateFromJson(Map<String, dynamic> json) =>
    ExpenseUpdate(
      amount: (json['amount'] as num?)?.toDouble(),
      category: json['category'] as String?,
      expenseDate: json['expense_date'] == null
          ? null
          : DateTime.parse(json['expense_date'] as String),
      notes: json['notes'] as String?,
      seasonLabel: json['season_label'] as String?,
      receiptFileId: json['receipt_file_id'] as String?,
    );

Map<String, dynamic> _$ExpenseUpdateToJson(ExpenseUpdate instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'category': instance.category,
      'expense_date': _dateToJson(instance.expenseDate),
      'notes': instance.notes,
      'season_label': instance.seasonLabel,
      'receipt_file_id': instance.receiptFileId,
    };

ExpenseListResponse _$ExpenseListResponseFromJson(Map<String, dynamic> json) =>
    ExpenseListResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$ExpenseListResponseToJson(
  ExpenseListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

IncomeRecord _$IncomeRecordFromJson(Map<String, dynamic> json) => IncomeRecord(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  crop: json['crop'] as String?,
  buyer: json['buyer'] as String?,
  incomeDate: DateTime.parse(json['income_date'] as String),
  pricePerUnit: (json['price_per_unit'] as num?)?.toDouble(),
  quantitySold: (json['quantity_sold'] as num?)?.toDouble(),
  totalRevenue: (json['total_revenue'] as num?)?.toDouble(),
  seasonLabel: json['season_label'] as String?,
  documentFileId: json['document_file_id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$IncomeRecordToJson(IncomeRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_user': instance.ownerUser,
      'crop': instance.crop,
      'buyer': instance.buyer,
      'income_date': _dateToJson(instance.incomeDate),
      'price_per_unit': instance.pricePerUnit,
      'quantity_sold': instance.quantitySold,
      'total_revenue': instance.totalRevenue,
      'season_label': instance.seasonLabel,
      'document_file_id': instance.documentFileId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

IncomeRecordCreate _$IncomeRecordCreateFromJson(Map<String, dynamic> json) =>
    IncomeRecordCreate(
      crop: json['crop'] as String?,
      buyer: json['buyer'] as String?,
      incomeDate: DateTime.parse(json['income_date'] as String),
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble(),
      quantitySold: (json['quantity_sold'] as num?)?.toDouble(),
      totalRevenue: (json['total_revenue'] as num?)?.toDouble(),
      seasonLabel: json['season_label'] as String?,
      documentFileId: json['document_file_id'] as String?,
    );

Map<String, dynamic> _$IncomeRecordCreateToJson(IncomeRecordCreate instance) =>
    <String, dynamic>{
      'crop': instance.crop,
      'buyer': instance.buyer,
      'income_date': _dateToJson(instance.incomeDate),
      'price_per_unit': instance.pricePerUnit,
      'quantity_sold': instance.quantitySold,
      'total_revenue': instance.totalRevenue,
      'season_label': instance.seasonLabel,
      'document_file_id': instance.documentFileId,
    };

IncomeRecordUpdate _$IncomeRecordUpdateFromJson(Map<String, dynamic> json) =>
    IncomeRecordUpdate(
      crop: json['crop'] as String?,
      buyer: json['buyer'] as String?,
      incomeDate: json['income_date'] == null
          ? null
          : DateTime.parse(json['income_date'] as String),
      pricePerUnit: (json['price_per_unit'] as num?)?.toDouble(),
      quantitySold: (json['quantity_sold'] as num?)?.toDouble(),
      totalRevenue: (json['total_revenue'] as num?)?.toDouble(),
      seasonLabel: json['season_label'] as String?,
      documentFileId: json['document_file_id'] as String?,
    );

Map<String, dynamic> _$IncomeRecordUpdateToJson(IncomeRecordUpdate instance) =>
    <String, dynamic>{
      'crop': instance.crop,
      'buyer': instance.buyer,
      'income_date': _dateToJson(instance.incomeDate),
      'price_per_unit': instance.pricePerUnit,
      'quantity_sold': instance.quantitySold,
      'total_revenue': instance.totalRevenue,
      'season_label': instance.seasonLabel,
      'document_file_id': instance.documentFileId,
    };

IncomeRecordListResponse _$IncomeRecordListResponseFromJson(
  Map<String, dynamic> json,
) => IncomeRecordListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => IncomeRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$IncomeRecordListResponseToJson(
  IncomeRecordListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

SeasonBudget _$SeasonBudgetFromJson(Map<String, dynamic> json) => SeasonBudget(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  seasonLabel: json['season_label'] as String,
  category: json['category'] as String?,
  budgetAmount: (json['budget_amount'] as num).toDouble(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SeasonBudgetToJson(SeasonBudget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_user': instance.ownerUser,
      'season_label': instance.seasonLabel,
      'category': instance.category,
      'budget_amount': instance.budgetAmount,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

SeasonBudgetCreate _$SeasonBudgetCreateFromJson(Map<String, dynamic> json) =>
    SeasonBudgetCreate(
      seasonLabel: json['season_label'] as String,
      category: json['category'] as String?,
      budgetAmount: (json['budget_amount'] as num).toDouble(),
    );

Map<String, dynamic> _$SeasonBudgetCreateToJson(SeasonBudgetCreate instance) =>
    <String, dynamic>{
      'season_label': instance.seasonLabel,
      'category': instance.category,
      'budget_amount': instance.budgetAmount,
    };

SeasonBudgetUpdate _$SeasonBudgetUpdateFromJson(Map<String, dynamic> json) =>
    SeasonBudgetUpdate(
      seasonLabel: json['season_label'] as String?,
      category: json['category'] as String?,
      budgetAmount: (json['budget_amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SeasonBudgetUpdateToJson(SeasonBudgetUpdate instance) =>
    <String, dynamic>{
      'season_label': instance.seasonLabel,
      'category': instance.category,
      'budget_amount': instance.budgetAmount,
    };

SeasonBudgetListResponse _$SeasonBudgetListResponseFromJson(
  Map<String, dynamic> json,
) => SeasonBudgetListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => SeasonBudget.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$SeasonBudgetListResponseToJson(
  SeasonBudgetListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

AiCropPlan _$AiCropPlanFromJson(Map<String, dynamic> json) => AiCropPlan(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  crop: json['crop'] as String?,
  priorityAction: json['priority_action'] as String?,
  recommendationText: json['recommendation_text'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AiCropPlanToJson(AiCropPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_user': instance.ownerUser,
      'crop': instance.crop,
      'priority_action': instance.priorityAction,
      'recommendation_text': instance.recommendationText,
      'created_at': instance.createdAt?.toIso8601String(),
    };

AiCropPlanCreate _$AiCropPlanCreateFromJson(Map<String, dynamic> json) =>
    AiCropPlanCreate(
      crop: json['crop'] as String?,
      priorityAction: json['priority_action'] as String?,
      recommendationText: json['recommendation_text'] as String?,
    );

Map<String, dynamic> _$AiCropPlanCreateToJson(AiCropPlanCreate instance) =>
    <String, dynamic>{
      'crop': instance.crop,
      'priority_action': instance.priorityAction,
      'recommendation_text': instance.recommendationText,
    };

AiCropPlanListResponse _$AiCropPlanListResponseFromJson(
  Map<String, dynamic> json,
) => AiCropPlanListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => AiCropPlan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$AiCropPlanListResponseToJson(
  AiCropPlanListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

AiInsight _$AiInsightFromJson(Map<String, dynamic> json) => AiInsight(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  category: json['category'] as String?,
  insightText: json['insight_text'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AiInsightToJson(AiInsight instance) => <String, dynamic>{
  'id': instance.id,
  'owner_user': instance.ownerUser,
  'category': instance.category,
  'insight_text': instance.insightText,
  'created_at': instance.createdAt?.toIso8601String(),
};

AiInsightCreate _$AiInsightCreateFromJson(Map<String, dynamic> json) =>
    AiInsightCreate(
      category: json['category'] as String?,
      insightText: json['insight_text'] as String?,
    );

Map<String, dynamic> _$AiInsightCreateToJson(AiInsightCreate instance) =>
    <String, dynamic>{
      'category': instance.category,
      'insight_text': instance.insightText,
    };

AiInsightListResponse _$AiInsightListResponseFromJson(
  Map<String, dynamic> json,
) => AiInsightListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => AiInsight.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$AiInsightListResponseToJson(
  AiInsightListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

AiMessage _$AiMessageFromJson(Map<String, dynamic> json) => AiMessage(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  sender: aiMessageSenderFromJson(json['sender']),
  messageText: json['message_text'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AiMessageToJson(AiMessage instance) => <String, dynamic>{
  'id': instance.id,
  'owner_user': instance.ownerUser,
  'sender': aiMessageSenderToJson(instance.sender),
  'message_text': instance.messageText,
  'created_at': instance.createdAt?.toIso8601String(),
};

AiMessageCreate _$AiMessageCreateFromJson(Map<String, dynamic> json) =>
    AiMessageCreate(
      sender: aiMessageCreateSenderFromJson(json['sender']),
      messageText: json['message_text'] as String,
    );

Map<String, dynamic> _$AiMessageCreateToJson(AiMessageCreate instance) =>
    <String, dynamic>{
      'sender': aiMessageCreateSenderToJson(instance.sender),
      'message_text': instance.messageText,
    };

AiMessageUpdate _$AiMessageUpdateFromJson(Map<String, dynamic> json) =>
    AiMessageUpdate(
      sender: aiMessageUpdateSenderNullableFromJson(json['sender']),
      messageText: json['message_text'] as String?,
    );

Map<String, dynamic> _$AiMessageUpdateToJson(AiMessageUpdate instance) =>
    <String, dynamic>{
      'sender': aiMessageUpdateSenderNullableToJson(instance.sender),
      'message_text': instance.messageText,
    };

AiMessageListResponse _$AiMessageListResponseFromJson(
  Map<String, dynamic> json,
) => AiMessageListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => AiMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$AiMessageListResponseToJson(
  AiMessageListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

CommunicationPreference _$CommunicationPreferenceFromJson(
  Map<String, dynamic> json,
) => CommunicationPreference(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  defaultChannel: json['default_channel'] as String?,
  notificationType: json['notification_type'] as String?,
  emailEnabled: json['email_enabled'] as bool? ?? false,
  smsEnabled: json['sms_enabled'] as bool? ?? false,
  whatsappEnabled: json['whatsapp_enabled'] as bool? ?? false,
  inAppEnabled: json['in_app_enabled'] as bool? ?? true,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$CommunicationPreferenceToJson(
  CommunicationPreference instance,
) => <String, dynamic>{
  'id': instance.id,
  'owner_user': instance.ownerUser,
  'default_channel': instance.defaultChannel,
  'notification_type': instance.notificationType,
  'email_enabled': instance.emailEnabled,
  'sms_enabled': instance.smsEnabled,
  'whatsapp_enabled': instance.whatsappEnabled,
  'in_app_enabled': instance.inAppEnabled,
  'updated_at': instance.updatedAt?.toIso8601String(),
};

CommunicationPreferenceCreate _$CommunicationPreferenceCreateFromJson(
  Map<String, dynamic> json,
) => CommunicationPreferenceCreate(
  defaultChannel: json['default_channel'] as String?,
  notificationType: json['notification_type'] as String?,
  emailEnabled: json['email_enabled'] as bool? ?? false,
  smsEnabled: json['sms_enabled'] as bool? ?? false,
  whatsappEnabled: json['whatsapp_enabled'] as bool? ?? false,
  inAppEnabled: json['in_app_enabled'] as bool? ?? true,
);

Map<String, dynamic> _$CommunicationPreferenceCreateToJson(
  CommunicationPreferenceCreate instance,
) => <String, dynamic>{
  'default_channel': instance.defaultChannel,
  'notification_type': instance.notificationType,
  'email_enabled': instance.emailEnabled,
  'sms_enabled': instance.smsEnabled,
  'whatsapp_enabled': instance.whatsappEnabled,
  'in_app_enabled': instance.inAppEnabled,
};

CommunicationPreferenceListResponse
_$CommunicationPreferenceListResponseFromJson(Map<String, dynamic> json) =>
    CommunicationPreferenceListResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) =>
                    CommunicationPreference.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$CommunicationPreferenceListResponseToJson(
  CommunicationPreferenceListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  notificationType: json['notification_type'] as String?,
  title: json['title'] as String?,
  shortMessage: json['short_message'] as String?,
  status: Notification.notificationStatusStatusFromJson(json['status']),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_user': instance.ownerUser,
      'notification_type': instance.notificationType,
      'title': instance.title,
      'short_message': instance.shortMessage,
      'status': notificationStatusToJson(instance.status),
      'created_at': instance.createdAt?.toIso8601String(),
    };

NotificationCreate _$NotificationCreateFromJson(Map<String, dynamic> json) =>
    NotificationCreate(
      notificationType: json['notification_type'] as String?,
      title: json['title'] as String?,
      shortMessage: json['short_message'] as String?,
      status: NotificationCreate.notificationCreateStatusStatusNullableFromJson(
        json['status'],
      ),
    );

Map<String, dynamic> _$NotificationCreateToJson(NotificationCreate instance) =>
    <String, dynamic>{
      'notification_type': instance.notificationType,
      'title': instance.title,
      'short_message': instance.shortMessage,
      'status': notificationCreateStatusNullableToJson(instance.status),
    };

NotificationListResponse _$NotificationListResponseFromJson(
  Map<String, dynamic> json,
) => NotificationListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$NotificationListResponseToJson(
  NotificationListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

NotificationDeliveryLog _$NotificationDeliveryLogFromJson(
  Map<String, dynamic> json,
) => NotificationDeliveryLog(
  id: json['id'] as String?,
  notificationId: json['notification_id'] as String?,
  channel: json['channel'] as String,
  deliveryStatus: json['delivery_status'] as String,
  deliveredAt: json['delivered_at'] == null
      ? null
      : DateTime.parse(json['delivered_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$NotificationDeliveryLogToJson(
  NotificationDeliveryLog instance,
) => <String, dynamic>{
  'id': instance.id,
  'notification_id': instance.notificationId,
  'channel': instance.channel,
  'delivery_status': instance.deliveryStatus,
  'delivered_at': instance.deliveredAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
};

NotificationDeliveryLogCreate _$NotificationDeliveryLogCreateFromJson(
  Map<String, dynamic> json,
) => NotificationDeliveryLogCreate(
  channel: json['channel'] as String,
  deliveryStatus: json['delivery_status'] as String,
  deliveredAt: json['delivered_at'] == null
      ? null
      : DateTime.parse(json['delivered_at'] as String),
);

Map<String, dynamic> _$NotificationDeliveryLogCreateToJson(
  NotificationDeliveryLogCreate instance,
) => <String, dynamic>{
  'channel': instance.channel,
  'delivery_status': instance.deliveryStatus,
  'delivered_at': instance.deliveredAt?.toIso8601String(),
};

NotificationDeliveryLogUpdate _$NotificationDeliveryLogUpdateFromJson(
  Map<String, dynamic> json,
) => NotificationDeliveryLogUpdate(
  channel: json['channel'] as String?,
  deliveryStatus: json['delivery_status'] as String?,
  deliveredAt: json['delivered_at'] == null
      ? null
      : DateTime.parse(json['delivered_at'] as String),
);

Map<String, dynamic> _$NotificationDeliveryLogUpdateToJson(
  NotificationDeliveryLogUpdate instance,
) => <String, dynamic>{
  'channel': instance.channel,
  'delivery_status': instance.deliveryStatus,
  'delivered_at': instance.deliveredAt?.toIso8601String(),
};

NotificationDeliveryLogListResponse
_$NotificationDeliveryLogListResponseFromJson(Map<String, dynamic> json) =>
    NotificationDeliveryLogListResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) =>
                    NotificationDeliveryLog.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$NotificationDeliveryLogListResponseToJson(
  NotificationDeliveryLogListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

Reminder _$ReminderFromJson(Map<String, dynamic> json) => Reminder(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  relatedActivityId: json['related_activity_id'] as String?,
  relatedCrop: json['related_crop'] as String?,
  title: json['title'] as String?,
  reminderDatetime: DateTime.parse(json['reminder_datetime'] as String),
  deliveryChannel: json['delivery_channel'] as String?,
  status: Reminder.reminderStatusStatusFromJson(json['status']),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'owner_user': instance.ownerUser,
  'related_activity_id': instance.relatedActivityId,
  'related_crop': instance.relatedCrop,
  'title': instance.title,
  'reminder_datetime': instance.reminderDatetime.toIso8601String(),
  'delivery_channel': instance.deliveryChannel,
  'status': reminderStatusToJson(instance.status),
  'created_at': instance.createdAt?.toIso8601String(),
};

ReminderCreate _$ReminderCreateFromJson(Map<String, dynamic> json) =>
    ReminderCreate(
      relatedActivityId: json['related_activity_id'] as String?,
      relatedCrop: json['related_crop'] as String?,
      title: json['title'] as String?,
      reminderDatetime: DateTime.parse(json['reminder_datetime'] as String),
      deliveryChannel: json['delivery_channel'] as String?,
      status: ReminderCreate.reminderCreateStatusStatusNullableFromJson(
        json['status'],
      ),
    );

Map<String, dynamic> _$ReminderCreateToJson(ReminderCreate instance) =>
    <String, dynamic>{
      'related_activity_id': instance.relatedActivityId,
      'related_crop': instance.relatedCrop,
      'title': instance.title,
      'reminder_datetime': instance.reminderDatetime.toIso8601String(),
      'delivery_channel': instance.deliveryChannel,
      'status': reminderCreateStatusNullableToJson(instance.status),
    };

ReminderUpdate _$ReminderUpdateFromJson(Map<String, dynamic> json) =>
    ReminderUpdate(
      relatedActivityId: json['related_activity_id'] as String?,
      relatedCrop: json['related_crop'] as String?,
      title: json['title'] as String?,
      reminderDatetime: json['reminder_datetime'] == null
          ? null
          : DateTime.parse(json['reminder_datetime'] as String),
      deliveryChannel: json['delivery_channel'] as String?,
      status: ReminderUpdate.reminderUpdateStatusStatusNullableFromJson(
        json['status'],
      ),
    );

Map<String, dynamic> _$ReminderUpdateToJson(ReminderUpdate instance) =>
    <String, dynamic>{
      'related_activity_id': instance.relatedActivityId,
      'related_crop': instance.relatedCrop,
      'title': instance.title,
      'reminder_datetime': instance.reminderDatetime?.toIso8601String(),
      'delivery_channel': instance.deliveryChannel,
      'status': reminderUpdateStatusNullableToJson(instance.status),
    };

ReminderListResponse _$ReminderListResponseFromJson(
  Map<String, dynamic> json,
) => ReminderListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$ReminderListResponseToJson(
  ReminderListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};

WeeklyReport _$WeeklyReportFromJson(Map<String, dynamic> json) => WeeklyReport(
  id: json['id'] as String?,
  ownerUser: json['owner_user'] as String?,
  reportText: json['report_text'] as String?,
  deliveryPreference: json['delivery_preference'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$WeeklyReportToJson(WeeklyReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_user': instance.ownerUser,
      'report_text': instance.reportText,
      'delivery_preference': instance.deliveryPreference,
      'created_at': instance.createdAt?.toIso8601String(),
    };

WeeklyReportCreate _$WeeklyReportCreateFromJson(Map<String, dynamic> json) =>
    WeeklyReportCreate(
      reportText: json['report_text'] as String?,
      deliveryPreference: json['delivery_preference'] as String?,
    );

Map<String, dynamic> _$WeeklyReportCreateToJson(WeeklyReportCreate instance) =>
    <String, dynamic>{
      'report_text': instance.reportText,
      'delivery_preference': instance.deliveryPreference,
    };

WeeklyReportListResponse _$WeeklyReportListResponseFromJson(
  Map<String, dynamic> json,
) => WeeklyReportListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => WeeklyReport.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$WeeklyReportListResponseToJson(
  WeeklyReportListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
};
