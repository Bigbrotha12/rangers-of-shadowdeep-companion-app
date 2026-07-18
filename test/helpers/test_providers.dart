import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/database/app_database_provider.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/session_repository.dart';
import 'package:rangers_mobile/data/repositories/session_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/companion_repository.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/ui/core/theme/preferences.dart';

/// Build a list of [Override]s for test [ProviderScope]s.
///
/// Pass an in-memory [AppDatabase] and a mock [SharedPreferences] to wire all
/// downstream providers.  Widget tests use these overrides so the widget tree
/// accesses real repositories backed by a test DB rather than the default
/// file-based database.
List<Override> buildTestOverrides({
  required AppDatabase database,
  required SharedPreferences sharedPreferences,
}) {
  return [
    appDatabaseProvider.overrideWithValue(database),
    sharedPrefsProvider.overrideWithValue(sharedPreferences),
    rangerRepositoryProvider.overrideWithValue(RangerRepository(database)),
    sessionRepositoryProvider.overrideWithValue(SessionRepository(database)),
    companionRepositoryProvider.overrideWithValue(CompanionRepository(database)),
  ];
}
