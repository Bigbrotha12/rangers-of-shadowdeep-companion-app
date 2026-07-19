import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:rangers_mobile/data/database/app_database.dart';

class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const _version = 1;

  Future<String> exportToJson() async {
    final data = {
      'rangers': (await _db.select(_db.rangers).get())
          .map((r) => r.toJson())
          .toList(),
      'ranger_abilities': (await _db.select(_db.rangerAbilities).get())
          .map((r) => r.toJson())
          .toList(),
      'ranger_skills': (await _db.select(_db.rangerSkills).get())
          .map((r) => r.toJson())
          .toList(),
      'ranger_companions': (await _db.select(_db.rangerCompanions).get())
          .map((r) => r.toJson())
          .toList(),
      'ranger_equipment': (await _db.select(_db.rangerEquipment).get())
          .map((r) => r.toJson())
          .toList(),
      'injuries': (await _db.select(_db.injuries).get())
          .map((r) => r.toJson())
          .toList(),
      'sessions': (await _db.select(_db.sessions).get())
          .map((r) => r.toJson())
          .toList(),
      'session_events': (await _db.select(_db.sessionEvents).get())
          .map((r) => r.toJson())
          .toList(),
    };

    final reference = {
      'companion_types': (await _db.select(_db.companionTypes).get())
          .map((r) => r.toJson())
          .toList(),
      'equipment': (await _db.select(_db.equipment).get())
          .map((r) => r.toJson())
          .toList(),
    };

    final backup = {
      'version': _version,
      'exported_at': DateTime.now().toIso8601String(),
      'data': data,
      'reference': reference,
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  Future<String> exportToFile() async {
    final json = await exportToJson();
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}_${_pad(now.hour)}-${_pad(now.minute)}-${_pad(now.second)}';
    final fileName = 'rangers_backup_$timestamp.json';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(json);
    return file.path;
  }

  Future<List<String>> listBackupFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.json') && p.basename(f.path).startsWith('rangers_backup_'),
    ).map((f) => f.path).toList();
    files.sort((a, b) => b.compareTo(a));
    return files;
  }

  Future<BackupImportResult> importFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return BackupImportResult.error('File not found: $path');
    }
    final json = await file.readAsString();
    return importFromJson(json);
  }

  Future<BackupImportResult> importFromJson(String jsonString) async {
    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final version = decoded['version'] as int?;
      if (version == null || version != _version) {
        return BackupImportResult.error(
          'Unsupported backup version: $version. Expected version $_version.',
        );
      }

      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) {
        return BackupImportResult.error('Invalid backup format: missing data.');
      }

      _validateSchema(data);

      final parsedRangers = (data['rangers'] as List)
          .map((j) => Ranger.fromJson(j as Map<String, dynamic>))
          .toList();
      final parsedAbilities = (data['ranger_abilities'] as List)
          .map((j) => RangerAbility.fromJson(j as Map<String, dynamic>))
          .toList();
      final parsedSkills = (data['ranger_skills'] as List)
          .map((j) => RangerSkill.fromJson(j as Map<String, dynamic>))
          .toList();
      final parsedCompanions = (data['ranger_companions'] as List)
          .map((j) => RangerCompanion.fromJson(j as Map<String, dynamic>))
          .toList();
      final parsedEquipment = (data['ranger_equipment'] as List)
          .map((j) => RangerEquipmentData.fromJson(j as Map<String, dynamic>))
          .toList();
      final parsedInjuries = (data['injuries'] as List)
          .map((j) => Injury.fromJson(j as Map<String, dynamic>))
          .toList();
      final parsedSessions = (data['sessions'] as List)
          .map((j) => Session.fromJson(j as Map<String, dynamic>))
          .toList();
      final parsedEvents = (data['session_events'] as List)
          .map((j) => SessionEvent.fromJson(j as Map<String, dynamic>))
          .toList();

      final backupReference = decoded['reference'] as Map<String, dynamic>?;
      final backupCompanionTypes = (backupReference?['companion_types'] as List?)
              ?.map((j) => CompanionType.fromJson(j as Map<String, dynamic>))
              .toList() ??
          <CompanionType>[];
      final backupEquipment = (backupReference?['equipment'] as List?)
              ?.map((j) => EquipmentData.fromJson(j as Map<String, dynamic>))
              .toList() ??
          <EquipmentData>[];

      await _db.transaction(() async {
        await _clearUserData();

        final currentCompanionTypes =
            await _db.select(_db.companionTypes).get();
        final currentEquipment = await _db.select(_db.equipment).get();

        final oldCompanionTypeIdToNew = <int, int>{};
        for (final backupCt in backupCompanionTypes) {
          final match = currentCompanionTypes.cast<CompanionType?>().firstWhere(
                (ct) => ct!.typeKey == backupCt.typeKey,
                orElse: () => null,
              );
          if (match != null) {
            oldCompanionTypeIdToNew[backupCt.id] = match.id;
          }
        }

        final oldEquipmentIdToNew = <int, int>{};
        for (final backupEq in backupEquipment) {
          final match = currentEquipment.cast<EquipmentData?>().firstWhere(
                (eq) => eq!.itemKey == backupEq.itemKey,
                orElse: () => null,
              );
          if (match != null) {
            oldEquipmentIdToNew[backupEq.id] = match.id;
          }
        }

        final rangerIdMap = <int, int>{};
        for (final r in parsedRangers) {
          final companion = r.toCompanion(true).copyWith(
                id: const Value.absent(),
              );
          final newId = await _db.into(_db.rangers).insert(companion);
          rangerIdMap[r.id] = newId;
        }

        for (final a in parsedAbilities) {
          final newRangerId = rangerIdMap[a.rangerId];
          if (newRangerId == null) continue;
          await _db.into(_db.rangerAbilities).insert(
                RangerAbilitiesCompanion(
                  rangerId: Value(newRangerId),
                  abilityType: Value(a.abilityType),
                  abilityKey: Value(a.abilityKey),
                  isUsedThisScenario: Value(a.isUsedThisScenario),
                ),
              );
        }

        for (final s in parsedSkills) {
          final newRangerId = rangerIdMap[s.rangerId];
          if (newRangerId == null) continue;
          await _db.into(_db.rangerSkills).insert(
                RangerSkillsCompanion(
                  rangerId: Value(newRangerId),
                  skillKey: Value(s.skillKey),
                  value: Value(s.value),
                ),
              );
        }

        final companionIdMap = <int, int>{};
        for (final c in parsedCompanions) {
          final newRangerId = rangerIdMap[c.rangerId];
          if (newRangerId == null) continue;
          final newTypeId = oldCompanionTypeIdToNew[c.companionTypeId] ??
              c.companionTypeId;
          final companion = c.toCompanion(true).copyWith(
                id: const Value.absent(),
                rangerId: Value(newRangerId),
                companionTypeId: Value(newTypeId),
              );
          final newId = await _db.into(_db.rangerCompanions).insert(companion);
          companionIdMap[c.id] = newId;
        }

        for (final e in parsedEquipment) {
          final newRangerId = rangerIdMap[e.rangerId];
          if (newRangerId == null) continue;
          final newEquipId =
              oldEquipmentIdToNew[e.equipmentId] ?? e.equipmentId;

          String remappedEquippedBy = e.equippedBy;
          if (e.equippedBy != 'ranger') {
            final oldCompanionId = int.tryParse(e.equippedBy);
            if (oldCompanionId != null) {
              final newCompanionId = companionIdMap[oldCompanionId];
              if (newCompanionId != null) {
                remappedEquippedBy = newCompanionId.toString();
              }
            }
          }

          await _db.into(_db.rangerEquipment).insert(
                RangerEquipmentCompanion(
                  rangerId: Value(newRangerId),
                  equipmentId: Value(newEquipId),
                  currentUses: e.currentUses == null
                      ? const Value.absent()
                      : Value(e.currentUses),
                  equippedBy: Value(remappedEquippedBy),
                ),
              );
        }

        final sessionIdMap = <int, int>{};
        for (final sess in parsedSessions) {
          final newRangerId = rangerIdMap[sess.rangerId];
          if (newRangerId == null) continue;
          final companion = sess.toCompanion(true).copyWith(
                id: const Value.absent(),
                rangerId: Value(newRangerId),
              );
          final newId = await _db.into(_db.sessions).insert(companion);
          sessionIdMap[sess.id] = newId;
        }

        for (final inj in parsedInjuries) {
          final newRangerId =
              inj.rangerId != null ? rangerIdMap[inj.rangerId] : null;
          final newCompanionId =
              inj.companionId != null ? companionIdMap[inj.companionId] : null;
          if (inj.rangerId != null && newRangerId == null) continue;
          if (inj.companionId != null && newCompanionId == null) continue;

          await _db.into(_db.injuries).insert(
                InjuriesCompanion(
                  injuryKey: Value(inj.injuryKey),
                  timesReceived: Value(inj.timesReceived),
                  receivedAt: Value(inj.receivedAt),
                  rangerId: newRangerId != null
                      ? Value<int?>(newRangerId)
                      : const Value.absent(),
                  companionId: newCompanionId != null
                      ? Value<int?>(newCompanionId)
                      : const Value.absent(),
                ),
              );
        }

        for (final evt in parsedEvents) {
          final newSessionId = sessionIdMap[evt.sessionId];
          if (newSessionId == null) continue;
          await _db.into(_db.sessionEvents).insert(
                SessionEventsCompanion(
                  sessionId: Value(newSessionId),
                  turnNumber: Value(evt.turnNumber),
                  phase: Value(evt.phase),
                  eventType: Value(evt.eventType),
                  description: Value(evt.description),
                  figureName: Value(evt.figureName),
                  createdAt: Value(evt.createdAt),
                ),
              );
        }
      });

      return BackupImportResult.success(
        rangers: parsedRangers.length,
        companions: parsedCompanions.length,
        sessions: parsedSessions.length,
      );
    } on Exception catch (e) {
      return BackupImportResult.error('Import failed: $e');
    }
  }

  Future<void> _clearUserData() async {
    await _db.delete(_db.sessionEvents).go();
    await _db.delete(_db.sessions).go();
    await _db.delete(_db.injuries).go();
    await _db.delete(_db.rangerEquipment).go();
    await _db.delete(_db.rangerCompanions).go();
    await _db.delete(_db.rangerSkills).go();
    await _db.delete(_db.rangerAbilities).go();
    await _db.delete(_db.rangers).go();
  }

  void _validateSchema(Map<String, dynamic> data) {
    const requiredTables = [
      'rangers',
      'ranger_abilities',
      'ranger_skills',
      'ranger_companions',
      'ranger_equipment',
      'injuries',
      'sessions',
      'session_events',
    ];
    for (final table in requiredTables) {
      if (!data.containsKey(table) || data[table] is! List) {
        throw FormatException('Invalid backup: missing or invalid "$table".');
      }
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class BackupImportResult {
  final bool success;
  final bool cancelled;
  final String? errorMessage;
  final int rangers;
  final int companions;
  final int sessions;

  const BackupImportResult({
    required this.success,
    this.cancelled = false,
    this.errorMessage,
    this.rangers = 0,
    this.companions = 0,
    this.sessions = 0,
  });

  factory BackupImportResult.success({
    int rangers = 0,
    int companions = 0,
    int sessions = 0,
  }) {
    return BackupImportResult(
      success: true,
      rangers: rangers,
      companions: companions,
      sessions: sessions,
    );
  }

  factory BackupImportResult.error(String message) {
    return BackupImportResult(
      success: false,
      errorMessage: message,
    );
  }

  factory BackupImportResult.cancelled() {
    return const BackupImportResult(
      success: false,
      cancelled: true,
    );
  }
}
