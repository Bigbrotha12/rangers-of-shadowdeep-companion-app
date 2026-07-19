import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database_provider.dart';
import 'package:rangers_mobile/data/repositories/companion_repository.dart';

final companionRepositoryProvider = Provider<CompanionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CompanionRepository(db);
});
