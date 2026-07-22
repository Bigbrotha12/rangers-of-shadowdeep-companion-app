import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';

class RangerEquipmentWithName {
  final RangerEquipmentData equipment;
  final String name;
  final String itemKey;
  final String category;
  final String effects;
  final int? slotIndex;
  final bool isActive;
  final Map<String, int> modifiers;

  RangerEquipmentWithName({
    required this.equipment,
    required this.name,
    required this.itemKey,
    required this.category,
    required this.effects,
    this.slotIndex,
    this.isActive = true,
    this.modifiers = const {},
  });
}

class RangerDetail {
  final Ranger ranger;
  final List<RangerAbility> abilities;
  final List<RangerSkill> skillBonuses;
  final List<RangerEquipmentWithName> equipment;
  final List<RangerCompanion> companions;
  final Map<int, List<String>> companionInjuryKeys;
  final Map<int, List<String>> companionHeroicAbilityKeys;
  final Map<int, List<RangerAbility>> companionSpellAbilities;
  final Map<int, Map<String, int>> companionCustomSkills;
  final List<String> statusEffects;
  final List<String> permanentInjuryKeys;

  RangerDetail({
    required this.ranger,
    required this.abilities,
    required this.skillBonuses,
    required this.equipment,
    required this.companions,
    this.companionInjuryKeys = const {},
    this.companionHeroicAbilityKeys = const {},
    this.companionSpellAbilities = const {},
    this.companionCustomSkills = const {},
    this.statusEffects = const [],
    this.permanentInjuryKeys = const [],
  });

  List<RangerAbility> get heroicAbilities =>
      abilities.where((a) => a.abilityType == 'heroic_ability').toList();

  List<RangerAbility> get spells =>
      abilities.where((a) => a.abilityType == 'spell').toList();

  Map<String, int> get equipmentModifiers {
    final result = <String, int>{};
    for (final item in equipment) {
      if (!item.isActive) continue;
      for (final entry in item.modifiers.entries) {
        result.update(entry.key, (v) => v + entry.value, ifAbsent: () => entry.value);
      }
    }
    return result;
  }
}

final rangerDetailProvider = FutureProvider.family<RangerDetail?, int>((ref, rangerId) async {
  final repo = ref.watch(rangerRepositoryProvider);
  final companionRepo = ref.watch(companionRepositoryProvider);
  
  final ranger = await repo.getRangerById(rangerId);
  if (ranger == null) return null;

  final abilities = await repo.getRangerAbilities(rangerId);
  final skillBonuses = await repo.getRangerSkills(rangerId);
  final equipmentRows = await repo.getRangerEquipment(rangerId);
  final companions = await companionRepo.getCompanionsByRanger(rangerId, isActive: true);

  // Load companion injury keys
  final companionInjuryKeys = <int, List<String>>{};
  for (final comp in companions) {
    companionInjuryKeys[comp.id] = await companionRepo.getCompanionInjuryKeys(comp.id);
  }

  // Load companion ability keys from shared ranger_abilities table
  final companionHeroicAbilityKeys = <int, List<String>>{};
  final companionSpellAbilities = <int, List<RangerAbility>>{};
  for (final comp in companions) {
    companionHeroicAbilityKeys[comp.id] = await companionRepo.getCompanionHeroicAbilityKeys(comp.id);
    companionSpellAbilities[comp.id] = await companionRepo.getCompanionSpellAbilities(comp.id);
  }

  // Load companion custom skills
  final companionCustomSkills = <int, Map<String, int>>{};
  for (final comp in companions) {
    companionCustomSkills[comp.id] = await companionRepo.getCompanionSkills(comp.id);
  }

  // Load equipment names
  String safeItemKey(EquipmentData? data) {
    if (data == null) return '';
    try {
      return data.itemKey;
    } on Exception catch (_) {
      return '';
    }
  }

    final equipment = <RangerEquipmentWithName>[];
    for (final item in equipmentRows) {
      final equipmentData = await repo.getEquipmentById(item.equipmentId);
      final modifiers = await repo.getEquipmentModifiers(item.equipmentId);
      equipment.add(RangerEquipmentWithName(
        equipment: item,
        name: equipmentData?.name ?? 'Unknown Item',
        itemKey: safeItemKey(equipmentData),
        category: equipmentData?.category ?? 'unknown',
        effects: equipmentData?.effects ?? '{}',
        slotIndex: item.slotIndex,
        isActive: item.isActive,
        modifiers: modifiers,
      ));
    }

  // Load status effects from normalized table
  final statusEffects = await repo.getRangerStatusEffectKeys(rangerId);

  // Parse permanent injury keys from notes
  final notes = ranger.notes;
  final injuryRegex = RegExp(r'\[Injury\]\s*(\w+(?:_\w+)*)');
  final permanentInjuryKeys = injuryRegex.allMatches(notes)
      .map((m) => m.group(1)!)
      .toList();

  return RangerDetail(
    ranger: ranger,
    abilities: abilities,
    skillBonuses: skillBonuses,
    equipment: equipment,
    companions: companions,
    companionInjuryKeys: companionInjuryKeys,
    companionHeroicAbilityKeys: companionHeroicAbilityKeys,
    companionSpellAbilities: companionSpellAbilities,
      companionCustomSkills: companionCustomSkills,
    statusEffects: statusEffects,
    permanentInjuryKeys: permanentInjuryKeys,
  );
});
