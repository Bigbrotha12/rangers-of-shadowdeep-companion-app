import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';

final companionTypesProvider = Provider<List<CompanionTypeDefinition>>((ref) {
  return companionTypes;
});
