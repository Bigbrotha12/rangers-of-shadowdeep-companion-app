import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database_provider.dart';
import 'ranger_repository.dart';

final rangerRepositoryProvider = Provider<RangerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RangerRepository(db);
});
