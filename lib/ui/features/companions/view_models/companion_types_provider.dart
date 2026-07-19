import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';

final companionTypesProvider = Provider<List<CompanionTypeDefinition>>((ref) {
  return companionTypes;
});

final humanCompanionTypesProvider = Provider<List<CompanionTypeDefinition>>((ref) {
  return humanCompanionTypes;
});

final animalCompanionTypesProvider = Provider<List<CompanionTypeDefinition>>((ref) {
  return animalCompanionTypes;
});

final companionTypeByKeyProvider = Provider.family<CompanionTypeDefinition?, String>((ref, key) {
  return getCompanionType(key);
});
