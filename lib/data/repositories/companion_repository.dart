import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';

class CompanionRepository {
  CompanionRepository(this._db);

  final AppDatabase _db;

  // Companion CRUD
  Future<int> insertCompanion(RangerCompanionsCompanion companion) async {
    return await _db.into(_db.rangerCompanions).insert(companion);
  }

  Future<RangerCompanion?> getCompanionById(int id) async {
    final query = _db.select(_db.rangerCompanions)
      ..where((c) => c.id.equals(id));
    return await query.getSingleOrNull();
  }

  Future<List<RangerCompanion>> getCompanionsByRanger(int rangerId, {bool? isActive}) async {
    final query = _db.select(_db.rangerCompanions)
      ..where((c) => c.rangerId.equals(rangerId));
    if (isActive != null) {
      query.where((c) => c.isActive.equals(isActive));
    }
    return await query.get();
  }

  Future<bool> updateCompanion(RangerCompanionsCompanion companion) async {
    final rows = await (_db.update(_db.rangerCompanions)..where((c) => c.id.equals(companion.id.value))).write(companion);
    return rows > 0;
  }

  Future<int> deleteCompanion(int id) async {
    // Delete related records first
    await (_db.delete(_db.injuries)..where((i) => i.companionId.equals(id))).go();
    await (_db.delete(_db.rangerAbilities)..where((a) => a.companionId.equals(id))).go();
    return await (_db.delete(_db.rangerCompanions)..where((c) => c.id.equals(id))).go();
  }

  // Companion Type lookup
  Future<CompanionType?> getCompanionTypeById(int typeId) async {
    final query = _db.select(_db.companionTypes)
      ..where((t) => t.id.equals(typeId));
    return await query.getSingleOrNull();
  }

  Future<List<CompanionType>> getAllCompanionTypes() async {
    return await _db.select(_db.companionTypes).get();
  }

  // Companion Abilities (ranger_abilities table)
  Future<Set<String>> getCompanionUsedAbilityKeys(int companionId) async {
    final rows = await (_db.select(_db.rangerAbilities)
      ..where((a) => a.companionId.equals(companionId))
      ..where((a) => a.isUsedThisScenario.equals(true))).get();
    return rows.map((r) => r.abilityKey).toSet();
  }

  Future<List<String>> getCompanionHeroicAbilityKeys(int companionId) async {
    final rows = await (_db.select(_db.rangerAbilities)
      ..where((a) => a.companionId.equals(companionId))
      ..where((a) => a.abilityType.equals('heroic_ability'))).get();
    return rows.map((r) => r.abilityKey).toList();
  }

  Future<List<String>> getCompanionSpellKeys(int companionId) async {
    final rows = await (_db.select(_db.rangerAbilities)
      ..where((a) => a.companionId.equals(companionId))
      ..where((a) => a.abilityType.equals('spell'))).get();
    return rows.map((r) => r.abilityKey).toList();
  }

  /// Returns the full `ranger_abilities` rows for a companion's spells,
  /// including the per-row `id` and `isUsedThisScenario` flag. The id is
  /// required to disambiguate duplicate spells and to persist usage state.
  Future<List<RangerAbility>> getCompanionSpellAbilities(int companionId) async {
    return await (_db.select(_db.rangerAbilities)
      ..where((a) => a.companionId.equals(companionId))
      ..where((a) => a.abilityType.equals('spell'))).get();
  }

  /// Returns all `ranger_abilities` rows for a companion (both heroic
  /// abilities and spells). The row id is needed to track spell usage state.
  Future<List<RangerAbility>> getCompanionAbilities(int companionId) async {
    return await (_db.select(_db.rangerAbilities)
      ..where((a) => a.companionId.equals(companionId))).get();
  }

  Future<void> addCompanionSpell(int companionId, int rangerId, String spellKey) async {
    await _db.into(_db.rangerAbilities).insert(RangerAbilitiesCompanion(
      rangerId: Value(rangerId),
      companionId: Value<int?>(companionId),
      abilityType: const Value('spell'),
      abilityKey: Value(spellKey),
    ));
  }

  Future<void> removeCompanionAbilityByIndex(int companionId, String abilityKey, String abilityType) async {
    final rows = await (_db.select(_db.rangerAbilities)
      ..where((a) => a.companionId.equals(companionId))
      ..where((a) => a.abilityKey.equals(abilityKey))
      ..where((a) => a.abilityType.equals(abilityType))
      ..limit(1)).get();
    if (rows.isNotEmpty) {
      await (_db.delete(_db.rangerAbilities)..where((a) => a.id.equals(rows.first.id))).go();
    }
  }

  Future<void> setCompanionAbilities(int companionId, int rangerId, String abilityType, List<String> keys) async {
    await (_db.delete(_db.rangerAbilities)
      ..where((a) => a.companionId.equals(companionId))
      ..where((a) => a.abilityType.equals(abilityType))).go();
    for (final key in keys) {
      await _db.into(_db.rangerAbilities).insert(RangerAbilitiesCompanion(
        rangerId: Value(rangerId),
        companionId: Value<int?>(companionId),
        abilityType: Value(abilityType),
        abilityKey: Value(key),
      ));
    }
  }

  Future<void> toggleCompanionAbilityUsed(int companionId, String abilityKey, bool used) async {
    await (_db.update(_db.rangerAbilities)
      ..where((a) => a.companionId.equals(companionId))
      ..where((a) => a.abilityKey.equals(abilityKey)))
      .write(RangerAbilitiesCompanion(isUsedThisScenario: Value(used)));
  }

  Future<void> resetCompanionScenarioAbilityUsage(int companionId) async {
    await (_db.update(_db.rangerAbilities)..where((a) => a.companionId.equals(companionId)))
      .write(const RangerAbilitiesCompanion(isUsedThisScenario: Value(false)));
  }

  // Companion Skills (companion_skills table)
  Future<Map<String, int>> getCompanionSkills(int companionId) async {
    final rows = await (_db.select(_db.companionSkills)
      ..where((s) => s.companionId.equals(companionId))).get();
    return {for (final r in rows) r.skillKey: r.value};
  }

  Future<void> upsertCompanionSkill(int companionId, String skillKey, int value) async {
    await (_db.delete(_db.companionSkills)
      ..where((s) => s.companionId.equals(companionId))
      ..where((s) => s.skillKey.equals(skillKey))).go();
    await _db.into(_db.companionSkills).insert(CompanionSkillsCompanion(
      companionId: Value(companionId),
      skillKey: Value(skillKey),
      value: Value(value),
    ));
  }

  // Companion Status Effects (status_effects table)
  Future<List<String>> getCompanionStatusEffectKeys(int companionId) async {
    final rows = await (_db.select(_db.statusEffects)
      ..where((s) => s.companionId.equals(companionId))).get();
    return rows.map((r) => r.statusEffectKey).toList();
  }

  Future<void> setCompanionStatusEffects(int companionId, List<String> keys) async {
    await (_db.delete(_db.statusEffects)
      ..where((s) => s.companionId.equals(companionId))).go();
    for (final key in keys) {
      await _db.into(_db.statusEffects).insert(StatusEffectsCompanion(
        companionId: Value<int?>(companionId),
        statusEffectKey: Value(key),
      ));
    }
  }

  // Companion Injuries (Injuries table)
  Future<List<String>> getCompanionInjuryKeys(int companionId) async {
    final rows = await (_db.select(_db.injuries)
      ..where((i) => i.companionId.equals(companionId))).get();
    return rows.map((r) => r.injuryKey).toList();
  }

  Future<void> addCompanionInjury(int companionId, String injuryKey) async {
    await _db.into(_db.injuries).insert(InjuriesCompanion(
      companionId: Value<int?>(companionId),
      injuryKey: Value(injuryKey),
      receivedAt: Value(DateTime.now()),
    ));
  }

  // Companion Progression Claims (companion_progression_claims table)
  Future<Set<int>> getClaimedThresholds(int companionId) async {
    final rows = await (_db.select(_db.companionProgressionClaims)
      ..where((c) => c.companionId.equals(companionId))).get();
    return rows.map((r) => r.threshold).toSet();
  }

  Future<void> markThresholdClaimed(int companionId, int threshold) async {
    await _db.into(_db.companionProgressionClaims).insert(
      CompanionProgressionClaimsCompanion.insert(
        companionId: companionId,
        threshold: threshold,
      ),
    );
  }

  Future<Map<int, Set<int>>> getClaimedThresholdsForCompanions(List<int> companionIds) async {
    if (companionIds.isEmpty) return {};
    final rows = await (_db.select(_db.companionProgressionClaims)
      ..where((c) => c.companionId.isIn(companionIds))).get();
    final result = <int, Set<int>>{};
    for (final r in rows) {
      result.putIfAbsent(r.companionId, () => {}).add(r.threshold);
    }
    return result;
  }
}
