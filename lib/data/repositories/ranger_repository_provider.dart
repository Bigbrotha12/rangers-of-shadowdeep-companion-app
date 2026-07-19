import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database_provider.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';

final rangerRepositoryProvider = Provider<RangerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RangerRepository(db);
});
