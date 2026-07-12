import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/constants/companion_types.dart';

final companionTypesProvider = Provider<List<CompanionType>>((ref) {
  return companionTypes;
});

final humanCompanionTypesProvider = Provider<List<CompanionType>>((ref) {
  return humanCompanionTypes;
});

final animalCompanionTypesProvider = Provider<List<CompanionType>>((ref) {
  return animalCompanionTypes;
});

final companionTypeByKeyProvider = Provider.family<CompanionType?, String>((ref, key) {
  return getCompanionType(key);
});
