import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/app_database.dart';

/// Create a test companion row for insertion into the ranger_companions table.
///
/// The [companionTypeId] must reference an existing companion_types row (the
/// seed data from the app database starts at id=1 for arcanist).
RangerCompanionsCompanion createTestCompanionCompanion({
  required int rangerId,
  required int companionTypeId,
  String customName = 'Test Companion',
  int progressionPoints = 0,
  bool isAlive = true,
}) {
  return RangerCompanionsCompanion(
    rangerId: Value(rangerId),
    companionTypeId: Value(companionTypeId),
    customName: Value(customName),
    progressionPoints: Value(progressionPoints),
    isAlive: Value(isAlive),
    isActive: const Value(true),
    createdAt: Value(DateTime.now()),
    hasUsedRecruitmentBonus: const Value(false),
    bonusHealth: const Value(0),
  );
}

/// Insert a test companion and return its auto-generated id.
Future<int> insertTestCompanion(
  AppDatabase db, {
  required int rangerId,
  required int companionTypeId,
  String customName = 'Test Companion',
}) async {
  final companion = createTestCompanionCompanion(
    rangerId: rangerId,
    companionTypeId: companionTypeId,
    customName: customName,
  );
  return await db.into(db.rangerCompanions).insert(companion);
}

/// Create an Injury companion for insertion.
InjuriesCompanion createTestInjury({
  int? rangerId,
  int? companionId,
  required String injuryKey,
  int timesReceived = 1,
}) {
  return InjuriesCompanion(
    rangerId: rangerId != null ? Value<int?>(rangerId) : const Value.absent(),
    companionId: companionId != null ? Value<int?>(companionId) : const Value.absent(),
    injuryKey: Value(injuryKey),
    timesReceived: Value(timesReceived),
    receivedAt: Value(DateTime.now()),
  );
}
