import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/ranger_repository_provider.dart';
import '../../../../data/repositories/companion_repository_provider.dart';

class RangerEquipmentWithName {
  final RangerEquipmentData equipment;
  final String name;
  final String category;

  RangerEquipmentWithName({
    required this.equipment,
    required this.name,
    required this.category,
  });
}

class RangerDetail {
  final Ranger ranger;
  final List<RangerAbility> abilities;
  final List<RangerSkill> skillBonuses;
  final List<RangerEquipmentWithName> equipment;
  final List<RangerCompanion> companions;

  RangerDetail({
    required this.ranger,
    required this.abilities,
    required this.skillBonuses,
    required this.equipment,
    required this.companions,
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
  final companions = await companionRepo.getCompanionsByRanger(rangerId);

  // Load equipment names
  final equipment = <RangerEquipmentWithName>[];
  for (final item in equipmentRows) {
    final equipmentData = await repo.getEquipmentById(item.equipmentId);
    equipment.add(RangerEquipmentWithName(
      equipment: item,
      name: equipmentData?.name ?? 'Unknown Item',
      category: equipmentData?.category ?? 'unknown',
    ));
  }

  return RangerDetail(
    ranger: ranger,
    abilities: abilities,
    skillBonuses: skillBonuses,
    equipment: equipment,
    companions: companions,
  );
});
