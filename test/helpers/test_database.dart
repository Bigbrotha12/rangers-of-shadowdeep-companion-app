import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:rangers_mobile/data/database/app_database.dart';

/// Creates an in-memory Drift [AppDatabase] for testing.
///
/// The migration runs automatically (creates all tables, seeds companion types
/// and equipment), so the returned database is ready for use immediately.
Future<AppDatabase> createTestDatabase() async {
  // Multiple test files create separate AppDatabase instances in the same
  // process; suppress the drift warning since each one uses its own in-memory
  // QueryExecutor, so no race conditions are possible.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
