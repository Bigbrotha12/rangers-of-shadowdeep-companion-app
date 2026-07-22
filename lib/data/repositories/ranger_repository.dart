import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';

class RangerRepository {
  RangerRepository(this._db);

  final AppDatabase _db;

  // Ranger CRUD
  Future<int> insertRanger(RangersCompanion companion) async {
    return await _db.into(_db.rangers).insert(companion);
  }

  Future<Ranger?> getRangerById(int id) async {
    final query = _db.select(_db.rangers)..where((r) => r.id.equals(id));
    return await query.getSingleOrNull();
  }

  Future<List<Ranger>> getRangers() async {
    final query = _db.select(_db.rangers);
    return await query.get();
  }

  Future<void> updateRangerFields(int rangerId, RangersCompanion companion) async {
    await (_db.update(_db.rangers)..where((r) => r.id.equals(rangerId))).write(companion);
  }

  Future<int> deleteRanger(int id) async {
    // Delete related records first
    await (_db.delete(_db.rangerAbilities)..where((a) => a.rangerId.equals(id))).go();
    await (_db.delete(_db.rangerSkills)..where((s) => s.rangerId.equals(id))).go();
    await (_db.delete(_db.rangerEquipment)..where((e) => e.rangerId.equals(id))).go();
    await (_db.delete(_db.rangerCompanions)..where((c) => c.rangerId.equals(id))).go();
    await (_db.delete(_db.injuries)..where((i) => i.rangerId.equals(id))).go();
    await (_db.delete(_db.sessions)..where((s) => s.rangerId.equals(id))).go();

    // Delete the ranger
    return await (_db.delete(_db.rangers)..where((r) => r.id.equals(id))).go();
  }

  // Ranger Abilities CRUD
  Future<int> insertRangerAbility(RangerAbilitiesCompanion companion) async {
    return await _db.into(_db.rangerAbilities).insert(companion);
  }

  Future<List<RangerAbility>> getRangerAbilities(int rangerId) async {
    final query = _db.select(_db.rangerAbilities)
      ..where((a) => a.rangerId.equals(rangerId))
      ..where((a) => a.companionId.isNull());
    return await query.get();
  }

  Future<void> toggleAbilityUsed(int abilityId, bool used) async {
    await (_db.update(_db.rangerAbilities)..where((a) => a.id.equals(abilityId)))
      .write(RangerAbilitiesCompanion(isUsedThisScenario: Value(used)));
  }

  Future<void> resetScenarioAbilityUsage(int rangerId) async {
    await (_db.update(_db.rangerAbilities)..where((a) => a.rangerId.equals(rangerId)))
      .write(const RangerAbilitiesCompanion(isUsedThisScenario: Value(false)));
  }

  // Ranger Skills CRUD
  Future<int> insertRangerSkill(RangerSkillsCompanion companion) async {
    return await _db.into(_db.rangerSkills).insert(companion);
  }

  Future<List<RangerSkill>> getRangerSkills(int rangerId) async {
    final query = _db.select(_db.rangerSkills)
      ..where((s) => s.rangerId.equals(rangerId));
    return await query.get();
  }

  Future<bool> updateRangerSkill(RangerSkillsCompanion companion) async {
    return await _db.update(_db.rangerSkills).replace(companion);
  }

  // Ranger Equipment CRUD
  Future<int> insertRangerEquipment(RangerEquipmentCompanion companion) async {
    return await _db.into(_db.rangerEquipment).insert(companion);
  }

  Future<List<RangerEquipmentData>> getRangerEquipment(int rangerId) async {
    final query = _db.select(_db.rangerEquipment)
      ..where((e) => e.rangerId.equals(rangerId));
    return await query.get();
  }

  Future<bool> updateRangerEquipment(RangerEquipmentCompanion companion) async {
    final rows = await (_db.update(_db.rangerEquipment)..where((e) => e.id.equals(companion.id.value))).write(companion);
    return rows > 0;
  }

  Future<int> deleteRangerEquipment(int id) async {
    return await (_db.delete(_db.rangerEquipment)..where((e) => e.id.equals(id))).go();
  }

  Future<bool> useEquipmentCharge(int id) async {
    final item = await (_db.select(_db.rangerEquipment)..where((e) => e.id.equals(id))).getSingleOrNull();
    if (item == null || item.currentUses == null || item.currentUses! <= 0) return false;
    final remaining = item.currentUses! - 1;
    if (remaining <= 0) {
      await deleteRangerEquipment(id);
      return true;
    }
    await (_db.update(_db.rangerEquipment)..where((e) => e.id.equals(id)))
      .write(RangerEquipmentCompanion(currentUses: Value(remaining)));
    return false;
  }

  // Ranger Status Effects (status_effects table)
  Future<List<String>> getRangerStatusEffectKeys(int rangerId) async {
    final rows = await (_db.select(_db.statusEffects)
      ..where((s) => s.rangerId.equals(rangerId))).get();
    return rows.map((r) => r.statusEffectKey).toList();
  }

  Future<void> setRangerStatusEffects(int rangerId, List<String> keys) async {
    await (_db.delete(_db.statusEffects)
      ..where((s) => s.rangerId.equals(rangerId))).go();
    for (final key in keys) {
      await _db.into(_db.statusEffects).insert(StatusEffectsCompanion(
        rangerId: Value<int?>(rangerId),
        statusEffectKey: Value(key),
      ));
    }
  }

  // Equipment lookup
  Future<EquipmentData?> getEquipmentByKey(String itemKey) async {
    final query = _db.select(_db.equipment)
      ..where((e) => e.itemKey.equals(itemKey));
    return await query.getSingleOrNull();
  }

  Future<EquipmentData?> getEquipmentById(int id) async {
    final query = _db.select(_db.equipment)
      ..where((e) => e.id.equals(id));
    return await query.getSingleOrNull();
  }

  Future<Map<String, int>> getEquipmentModifiers(int equipmentId) async {
    final rows = await (_db.select(_db.equipmentEffectModifiers)
      ..where((m) => m.equipmentId.equals(equipmentId))).get();
    return {for (final r in rows) r.statKey: r.modifier};
  }

  Future<List<EquipmentData>> getAllEquipment() async {
    return await _db.select(_db.equipment).get();
  }
}
