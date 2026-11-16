// GENERATED FILE -- do not hand-edit.
// Source: packages/shared/openapi/openapi.yaml
// Regenerate via: npm run generate:models (packages/shared)

export '_generated/openapi.models.swagger.dart'
    show FarmProfile, FarmProfileCreate, FarmProfileListResponse;

import '_generated/openapi.models.swagger.dart';

extension FarmProfileExtension on FarmProfile {
  List<String> get selectedCrops => [primaryCrop, secondaryCrop]
      .whereType<String>()
      .map((c) => c.trim())
      .where((c) => c.isNotEmpty)
      .toList();
}
