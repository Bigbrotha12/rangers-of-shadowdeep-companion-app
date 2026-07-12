import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database_provider.dart';
import 'companion_repository.dart';

final companionRepositoryProvider = Provider<CompanionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CompanionRepository(db);
});
