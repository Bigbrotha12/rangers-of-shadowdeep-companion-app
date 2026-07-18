import 'package:drift/native.dart';
import 'package:rangers_mobile/data/database/app_database.dart';

/// Creates an in-memory Drift [AppDatabase] for testing.
///
/// The migration runs automatically (creates all tables, seeds companion types
/// and equipment), so the returned database is ready for use immediately.
Future<AppDatabase> createTestDatabase() async {
  return AppDatabase(NativeDatabase.memory());
}
