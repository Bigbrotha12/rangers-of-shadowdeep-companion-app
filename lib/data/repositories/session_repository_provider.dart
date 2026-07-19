import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database_provider.dart';
import 'package:rangers_mobile/data/repositories/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionRepository(db);
});
