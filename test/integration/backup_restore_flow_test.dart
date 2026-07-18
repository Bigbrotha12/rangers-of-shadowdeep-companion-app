import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/services/backup_service.dart';
import 'package:rangers_mobile/data/services/backup_service_provider.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/router.dart';
import '../fixtures/ranger_data.dart';
import '../helpers/test_database.dart';
import '../helpers/mock_shared_preferences.dart';
import '../helpers/test_providers.dart';

GoRouter createTestRouter({String initialLocation = '/settings'}) => GoRouter(
  initialLocation: initialLocation,
  routes: appRouter.configuration.routes,
);

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = await createTestDatabase();
  });

  Future<void> pumpApp(WidgetTester tester, GoRouter router, {List<Override>? extraOverrides}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...buildTestOverrides(database: db, sharedPreferences: prefs),
          if (extraOverrides != null) ...extraOverrides,
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('settings view shows data backup section', (tester) async {
    final router = createTestRouter();
    await pumpApp(tester, router);

    expect(find.text('Settings'), findsAtLeast(1));
    expect(find.text('Data Backup'), findsOneWidget);
    expect(find.text('Export backup'), findsOneWidget);
    expect(find.text('Import backup'), findsOneWidget);
  });

  testWidgets('import shows no backup files warning when empty', (tester) async {
    // Override BackupService with one that returns empty file list
    final fakeService = FakeBackupService(db);

    final router = createTestRouter();
    await pumpApp(tester, router, extraOverrides: [
      backupServiceProvider.overrideWithValue(fakeService),
    ]);

    // Tap "Import backup"
    await tester.tap(find.text('Import backup'));
    await tester.pumpAndSettle();

    expect(find.text('No backup files found. Export a backup first.'), findsOneWidget);
  });

  testWidgets('export creates backup and import restores data', (tester) async {
    final rangerRepo = RangerRepository(db);
    final rangerId = await rangerRepo.insertRanger(
      createTestRangerCompanion(name: 'Gimli'),
    );

    final fakeService = FakeBackupService(db);

    final router = createTestRouter();
    await pumpApp(tester, router, extraOverrides: [
      backupServiceProvider.overrideWithValue(fakeService),
    ]);

    // Export
    await tester.tap(find.text('Export backup'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Backup saved:').evaluate().isNotEmpty,
      isTrue,
    );

    // Verify backup has our ranger
    final json = fakeService.lastExportedJson;
    expect(json, isNotNull);
    expect(json!.contains('Gimli'), isTrue);

    // Clear DB
    await rangerRepo.deleteRanger(rangerId);

    // Verify ranger is gone
    var rangers = await rangerRepo.getRangers();
    expect(rangers.length, 0);

    // Import from the JSON
    fakeService.addBackupFile(json);
    await tester.tap(find.text('Import backup'));
    await tester.pumpAndSettle();

    // Should show file selection dialog
    expect(find.text('Select backup'), findsOneWidget);

    // Select the file (find by the exact subtitle which contains the path)
    await tester.tap(find.text('/fake/path/to/rangers_backup_2026-01-01_12-00-00.json'));
    await tester.pumpAndSettle();

    // Should show confirmation dialog
    expect(find.text('Import'), findsOneWidget);

    // Confirm import
    await tester.tap(find.widgetWithText(FilledButton, 'Import'));
    await tester.pumpAndSettle();

    // Advance past the 1.5s navigation delay
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Check results
    rangers = await rangerRepo.getRangers();
    expect(rangers.length, 1);
    expect(rangers.first.name, 'Gimli');
  });
}

class FakeBackupService extends BackupService {
  FakeBackupService(super.db);

  String? _lastExportedJson;
  final List<String> _backupFiles = [];

  String? get lastExportedJson => _lastExportedJson;

  void addBackupFile(String json) {
    _backupFiles.add('/fake/path/to/rangers_backup_2026-01-01_12-00-00.json');
    _storedJsons['/fake/path/to/rangers_backup_2026-01-01_12-00-00.json'] = json;
  }

  final _storedJsons = <String, String>{};

  @override
  Future<String> exportToFile() async {
    _lastExportedJson = await exportToJson();
    return '/fake/path/to/rangers_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
  }

  @override
  Future<List<String>> listBackupFiles() async {
    return List.unmodifiable(_backupFiles);
  }

  @override
  Future<BackupImportResult> importFromFile(String path) async {
    final json = _storedJsons[path];
    if (json == null) {
      return BackupImportResult.error('File not found: $path');
    }
    return importFromJson(json);
  }
}
