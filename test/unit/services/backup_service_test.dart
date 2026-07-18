import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/data/services/backup_service.dart';
import '../../helpers/test_database.dart';

void main() {
  late BackupService service;

  setUp(() async {
    final db = await createTestDatabase();
    service = BackupService(db);
  });

  group('exportToJson', () {
    test('returns valid JSON with correct structure', () async {
      final json = await service.exportToJson();
      expect(json, isA<String>());

      final decoded = Uri.tryParse('data:application/json,$json');
      expect(decoded, isNotNull);
    });

    test('contains version and data keys', () async {
      final json = await service.exportToJson();
      expect(json, contains('"version"'));
      expect(json, contains('"data"'));
      expect(json, contains('"reference"'));
    });

    test('contains all 8 user data tables', () async {
      final json = await service.exportToJson();
      expect(json, contains('"rangers"'));
      expect(json, contains('"ranger_abilities"'));
      expect(json, contains('"ranger_skills"'));
      expect(json, contains('"ranger_companions"'));
      expect(json, contains('"ranger_equipment"'));
      expect(json, contains('"injuries"'));
      expect(json, contains('"sessions"'));
      expect(json, contains('"session_events"'));
    });
  });

  group('importFromJson', () {
    test('empty import succeeds with zero counts', () async {
      final json = '''{
        "version": 1,
        "exported_at": "2024-01-01T00:00:00",
        "data": {
          "rangers": [],
          "ranger_abilities": [],
          "ranger_skills": [],
          "ranger_companions": [],
          "ranger_equipment": [],
          "injuries": [],
          "sessions": [],
          "session_events": []
        }
      }''';

      final result = await service.importFromJson(json);
      expect(result.success, isTrue);
      expect(result.rangers, 0);
      expect(result.companions, 0);
      expect(result.sessions, 0);
    });

    test('version mismatch returns error', () async {
      final json = '''{
        "version": 999,
        "data": {
          "rangers": [],
          "ranger_abilities": [],
          "ranger_skills": [],
          "ranger_companions": [],
          "ranger_equipment": [],
          "injuries": [],
          "sessions": [],
          "session_events": []
        }
      }''';

      final result = await service.importFromJson(json);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Unsupported backup version'));
    });

    test('missing version returns error', () async {
      final json = '''{
        "data": {
          "rangers": [],
          "ranger_abilities": [],
          "ranger_skills": [],
          "ranger_companions": [],
          "ranger_equipment": [],
          "injuries": [],
          "sessions": [],
          "session_events": []
        }
      }''';

      final result = await service.importFromJson(json);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Unsupported backup version'));
    });

    test('missing data returns error', () async {
      final json = '{"version": 1}';

      final result = await service.importFromJson(json);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('missing data'));
    });

    test('missing table in data returns error', () async {
      final json = '''{
        "version": 1,
        "data": {
          "rangers": [],
          "ranger_abilities": [],
          "ranger_skills": [],
          "ranger_companions": [],
          "ranger_equipment": [],
          "injuries": [],
          "sessions": []
        }
      }''';

      final result = await service.importFromJson(json);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Invalid backup'));
    });

    test('corrupted JSON returns error', () async {
      final result = await service.importFromJson('not valid json');
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Import failed'));
    });
  });
}
