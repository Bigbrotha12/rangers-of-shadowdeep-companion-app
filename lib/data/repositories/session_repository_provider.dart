import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database_provider.dart';
import 'session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionRepository(db);
});
