import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';

/// A default test ranger companion built with base stats.
///
/// id is omitted so Drift auto-assigns on insert.
RangersCompanion createTestRangerCompanion({
  String name = 'Test Ranger',
  int level = 0,
  int experiencePoints = 0,
  int baseRecruitmentPoints = 100,
  int move = 6,
  int fight = 2,
  int shoot = 1,
  int armour = 10,
  int will = 4,
  int health = 18,
  int? currentHealth,
}) {
  final now = DateTime.now();
  return RangersCompanion(
    name: Value(name),
    level: Value(level),
    experiencePoints: Value(experiencePoints),
    baseRecruitmentPoints: Value(baseRecruitmentPoints),
    move: Value(move),
    fight: Value(fight),
    shoot: Value(shoot),
    armour: Value(armour),
    will: Value(will),
    health: Value(health),
    currentHealth: Value(currentHealth ?? health),
    createdAt: Value(now),
    updatedAt: Value(now),
    notes: const Value(''),
  );
}

/// Insert a test ranger into [db] and return its auto-generated id.
Future<int> insertTestRanger(AppDatabase db, {String name = 'Test Ranger'}) async {
  final companion = createTestRangerCompanion(name: name);
  return await db.into(db.rangers).insert(companion);
}

/// Helper: create a [RangerAbilitiesCompanion] for a ranger ability or spell.
RangerAbilitiesCompanion createTestRangerAbility({
  required int rangerId,
  required String abilityType,
  required String abilityKey,
}) {
  return RangerAbilitiesCompanion(
    rangerId: Value(rangerId),
    abilityType: Value(abilityType),
    abilityKey: Value(abilityKey),
    isUsedThisScenario: const Value(false),
  );
}

/// Helper: create a [RangerSkillsCompanion].
RangerSkillsCompanion createTestRangerSkill({
  required int rangerId,
  required String skillKey,
  required int value,
}) {
  return RangerSkillsCompanion(
    rangerId: Value(rangerId),
    skillKey: Value(skillKey),
    value: Value(value),
  );
}

/// Helper: create a [RangerEquipmentCompanion] (links ranger to equipment).
RangerEquipmentCompanion createTestRangerEquipment({
  required int rangerId,
  required int equipmentId,
  int? currentUses,
  String equippedBy = 'ranger',
}) {
  return RangerEquipmentCompanion(
    rangerId: Value(rangerId),
    equipmentId: Value(equipmentId),
    currentUses: currentUses != null ? Value(currentUses) : const Value.absent(),
    equippedBy: Value(equippedBy),
    isActive: const Value(true),
  );
}

/// Look up a seed-equipment id by its [itemKey].
///
/// Throws if the item is not found (e.g. the seed data hasn't run).
Future<int> getEquipmentId(AppDatabase db, String itemKey) async {
  final repo = RangerRepository(db);
  final item = await repo.getEquipmentByKey(itemKey);
  if (item == null) throw StateError('Equipment "$itemKey" not found in seed data');
  return item.id;
}

/// Insert a full test ranger with abilities, skills, and equipment.
/// Uses seed equipment records so no UNIQUE-constraint conflicts occur.
/// Returns the ranger id.
Future<int> insertFullTestRanger(AppDatabase db) async {
  final rangerId = await insertTestRanger(db);

  // Add heroic ability and spell
  await db.into(db.rangerAbilities).insert(createTestRangerAbility(
    rangerId: rangerId,
    abilityType: 'heroic_ability',
    abilityKey: 'dash',
  ));
  await db.into(db.rangerAbilities).insert(createTestRangerAbility(
    rangerId: rangerId,
    abilityType: 'spell',
    abilityKey: 'heal',
  ));

  // Add skills
  await db.into(db.rangerSkills).insert(createTestRangerSkill(
    rangerId: rangerId,
    skillKey: 'ancient_lore',
    value: 3,
  ));
  await db.into(db.rangerSkills).insert(createTestRangerSkill(
    rangerId: rangerId,
    skillKey: 'perception',
    value: 2,
  ));

  // Equip seed items (hand_weapon, light_armour)
  final handWeaponId = await getEquipmentId(db, 'hand_weapon');
  final lightArmourId = await getEquipmentId(db, 'light_armour');

  await db.into(db.rangerEquipment).insert(createTestRangerEquipment(
    rangerId: rangerId,
    equipmentId: handWeaponId,
  ));
  await db.into(db.rangerEquipment).insert(createTestRangerEquipment(
    rangerId: rangerId,
    equipmentId: lightArmourId,
  ));

  return rangerId;
}
