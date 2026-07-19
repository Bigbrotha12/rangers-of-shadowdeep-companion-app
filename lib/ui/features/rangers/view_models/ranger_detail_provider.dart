import 'dart:convert';

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

  RangerEquipmentWithName({
    required this.equipment,
    required this.name,
    required this.itemKey,
    required this.category,
    required this.effects,
    this.slotIndex,
    this.isActive = true,
  });
}

class RangerDetail {
  final Ranger ranger;
  final List<RangerAbility> abilities;
  final List<RangerSkill> skillBonuses;
  final List<RangerEquipmentWithName> equipment;
  final List<RangerCompanion> companions;
  final List<String> statusEffects;
  final List<String> permanentInjuryKeys;

  RangerDetail({
    required this.ranger,
    required this.abilities,
    required this.skillBonuses,
    required this.equipment,
    required this.companions,
    this.statusEffects = const [],
    this.permanentInjuryKeys = const [],
  });

  List<RangerAbility> get heroicAbilities =>
      abilities.where((a) => a.abilityType == 'heroic_ability').toList();

  List<RangerAbility> get spells =>
      abilities.where((a) => a.abilityType == 'spell').toList();
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
      equipment.add(RangerEquipmentWithName(
        equipment: item,
        name: equipmentData?.name ?? 'Unknown Item',
        itemKey: safeItemKey(equipmentData),
        category: equipmentData?.category ?? 'unknown',
        effects: equipmentData?.effects ?? '{}',
        slotIndex: item.slotIndex,
        isActive: item.isActive,
      ));
    }

  // Parse status effects from JSON column
  final statusEffects = List<String>.from(
    jsonDecode(ranger.statusEffects) as List? ?? [],
  );

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
    statusEffects: statusEffects,
    permanentInjuryKeys: permanentInjuryKeys,
  );
});
