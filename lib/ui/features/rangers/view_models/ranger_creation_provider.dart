import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/domain/constants/base_stats.dart';

class RangerCreationState {
  final int currentStep;
  final String name;
  final String notes;

  // Build Points
  final int totalBuildPoints;
  final Map<String, int> statBonuses; // stat key -> bonus value (max 1 per stat)
  final List<String> selectedHeroicAbilities;
  final Map<String, int> selectedSpells;
  final Map<String, int> skillBonuses; // skill key -> bonus value
  final int recruitmentPointsBonus; // +10 RP per BP spent

  // Starting Equipment
  final List<String> selectedEquipment; // item keys

  RangerCreationState({
    this.currentStep = 0,
    this.name = '',
    this.notes = '',
    this.totalBuildPoints = 10,
    this.statBonuses = const {},
    this.selectedHeroicAbilities = const [],
    this.selectedSpells = const {},
    this.skillBonuses = const {},
    this.recruitmentPointsBonus = 0,
    this.selectedEquipment = const [],
  });

  int get remainingBuildPoints => totalBuildPoints - totalSpent;

  int get statPointsSpent => statBonuses.values.fold(0, (sum, v) => sum + v);

  int get abilityPointsSpent =>
      selectedHeroicAbilities.length +
      selectedSpells.values.fold(0, (sum, v) => sum + v);

  int get skillPointsSpent {
    if (skillBonuses.isEmpty) return 0;
    final totalPoints = skillBonuses.values.fold(0, (sum, v) => sum + v);
    final impliedByTotal = (totalPoints / 8).ceil();
    final impliedByMax = skillBonuses.values.fold(0, (a, b) => a > b ? a : b);
    return impliedByTotal > impliedByMax ? impliedByTotal : impliedByMax;
  }

  int get rpPointsSpent => recruitmentPointsBonus ~/ 10;

  int get totalSpent =>
      statPointsSpent + abilityPointsSpent + skillPointsSpent + rpPointsSpent;

  int get effectiveMaxStats =>
      min(maxStatBuildPoints, totalBuildPoints - (totalSpent - statPointsSpent));

  int get effectiveMaxAbilities =>
      min(maxHeroicAbilityBuildPoints, totalBuildPoints - (totalSpent - abilityPointsSpent));

  int get effectiveMaxSkills =>
      min(maxSkillBuildPoints, totalBuildPoints - (totalSpent - skillPointsSpent));

  int get effectiveMaxRP =>
      min(maxRecruitmentPointBuildPoints, totalBuildPoints - (totalSpent - rpPointsSpent));

  bool get canSpendOnStats => statPointsSpent < effectiveMaxStats;

  bool get canSpendOnAbilities => abilityPointsSpent < effectiveMaxAbilities;

  bool get canSpendOnSkills {
    final totalSkillPoints = skillBonuses.values.fold(0, (sum, v) => sum + v);
    return totalSkillPoints < effectiveMaxSkills * 8;
  }

  bool get canSpendOnRP => rpPointsSpent < effectiveMaxRP;

  bool get isStep1Valid => name.trim().isNotEmpty;

  bool get isStep2Valid => true; // Always valid, just spending points

  bool get isStep3Valid => true; // Optional equipment

  bool get isStep4Valid => isStep1Valid;

  bool get canProceed {
    switch (currentStep) {
      case 0:
        return isStep1Valid;
      case 1:
        return isStep2Valid;
      case 2:
        return isStep3Valid;
      case 3:
        return isStep4Valid;
      default:
        return false;
    }
  }

  // Calculate effective stats after creation
  int getEffectiveStat(String stat, int baseValue) {
    return baseValue + (statBonuses[stat] ?? 0);
  }

  // Calculate total recruitment points
  int get totalRecruitmentPoints =>
      startingBaseRecruitmentPoints + recruitmentPointsBonus;
}

class RangerCreationNotifier extends StateNotifier<RangerCreationState> {
  RangerCreationNotifier() : super(RangerCreationState());

  void setStep(int step) {
    state = RangerCreationState(
      currentStep: step,
      name: state.name,
      notes: state.notes,
      statBonuses: state.statBonuses,
      selectedHeroicAbilities: state.selectedHeroicAbilities,
      selectedSpells: state.selectedSpells,
      skillBonuses: state.skillBonuses,
      recruitmentPointsBonus: state.recruitmentPointsBonus,
      selectedEquipment: state.selectedEquipment,
    );
  }

  void nextStep() {
    if (state.currentStep < 3) {
      setStep(state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      setStep(state.currentStep - 1);
    }
  }

  void updateName(String name) {
    state = RangerCreationState(
      currentStep: state.currentStep,
      name: name,
      notes: state.notes,
      statBonuses: state.statBonuses,
      selectedHeroicAbilities: state.selectedHeroicAbilities,
      selectedSpells: state.selectedSpells,
      skillBonuses: state.skillBonuses,
      recruitmentPointsBonus: state.recruitmentPointsBonus,
      selectedEquipment: state.selectedEquipment,
    );
  }

  void updateNotes(String notes) {
    state = RangerCreationState(
      currentStep: state.currentStep,
      name: state.name,
      notes: notes,
      statBonuses: state.statBonuses,
      selectedHeroicAbilities: state.selectedHeroicAbilities,
      selectedSpells: state.selectedSpells,
      skillBonuses: state.skillBonuses,
      recruitmentPointsBonus: state.recruitmentPointsBonus,
      selectedEquipment: state.selectedEquipment,
    );
  }

  // Stat bonuses: +1 per stat, max 3 total
  bool toggleStatBonus(String stat) {
    final current = state.statBonuses[stat] ?? 0;
    if (current > 0) {
      // Remove bonus
      final newBonuses = Map<String, int>.from(state.statBonuses);
      newBonuses.remove(stat);
      _updateState(statBonuses: newBonuses);
      return true;
    } else if (state.statPointsSpent < 3) {
      // Add bonus
      final newBonuses = Map<String, int>.from(state.statBonuses);
      newBonuses[stat] = 1;
      _updateState(statBonuses: newBonuses);
      return true;
    }
    return false;
  }

  // Heroic Abilities: 1 BP each, max 5 BP
  bool toggleHeroicAbility(String abilityKey) {
    if (state.selectedHeroicAbilities.contains(abilityKey)) {
      final newAbilities = List<String>.from(state.selectedHeroicAbilities);
      newAbilities.remove(abilityKey);
      _updateState(selectedHeroicAbilities: newAbilities);
      return true;
    } else if (state.canSpendOnAbilities) {
      final newAbilities = List<String>.from(state.selectedHeroicAbilities);
      newAbilities.add(abilityKey);
      _updateState(selectedHeroicAbilities: newAbilities);
      return true;
    }
    return false;
  }

  // Spells: 1 BP each, max 5 BP
  bool addSpell(String spellKey) {
    if (!state.canSpendOnAbilities) return false;
    final currentCount = state.selectedSpells[spellKey] ?? 0;
    final newSpells = Map<String, int>.from(state.selectedSpells);
    newSpells[spellKey] = currentCount + 1;
    _updateState(selectedSpells: newSpells);
    return true;
  }

  bool removeSpell(String spellKey) {
    final currentCount = state.selectedSpells[spellKey] ?? 0;
    if (currentCount <= 0) return false;
    final newSpells = Map<String, int>.from(state.selectedSpells);
    if (currentCount <= 1) {
      newSpells.remove(spellKey);
    } else {
      newSpells[spellKey] = currentCount - 1;
    }
    _updateState(selectedSpells: newSpells);
    return true;
  }

  // Skills: 1 BP = +1 to 8 skills, max 5 BP
  bool updateSkillBonus(String skillKey, int delta) {
    final current = state.skillBonuses[skillKey] ?? 0;
    final newValue = current + delta;

    if (newValue < 0) return false;

    final newBonuses = Map<String, int>.from(state.skillBonuses);
    if (newValue == 0) {
      newBonuses.remove(skillKey);
    } else {
      newBonuses[skillKey] = newValue;
    }

    final totalSkillPoints = newBonuses.values.fold(0, (sum, v) => sum + v);
    final impliedByTotal = (totalSkillPoints / 8).ceil();
    final impliedByMax = newBonuses.values.fold(0, (a, b) => a > b ? a : b);
    final newSkillPointsSpent = impliedByTotal > impliedByMax ? impliedByTotal : impliedByMax;

    // Per-skill cap: no skill can exceed the total BP available for this section
    if (newValue > state.effectiveMaxSkills) return false;

    // Section cap
    if (newSkillPointsSpent > maxSkillBuildPoints) return false;

    // Global BP cap
    final newTotalSpent = state.totalSpent - state.skillPointsSpent + newSkillPointsSpent;
    if (newTotalSpent > state.totalBuildPoints) return false;

    _updateState(skillBonuses: newBonuses);
    return true;
  }

  // Recruitment Points: +10 RP per BP, max 3 BP
  bool toggleRecruitmentPoints() {
    if (state.canSpendOnRP) {
      _updateState(
          recruitmentPointsBonus: state.recruitmentPointsBonus + 10);
      return true;
    }
    return false;
  }

  bool removeRecruitmentPoint() {
    if (state.recruitmentPointsBonus > 0) {
      _updateState(
          recruitmentPointsBonus: state.recruitmentPointsBonus - 10);
      return true;
    }
    return false;
  }

  // Equipment: select/deselect items
  bool toggleEquipment(String itemKey) {
    if (state.selectedEquipment.contains(itemKey)) {
      final newEquipment = List<String>.from(state.selectedEquipment);
      newEquipment.remove(itemKey);
      _updateState(selectedEquipment: newEquipment);
      return true;
    } else if (state.selectedEquipment.length < maxStartingEquipmentItems) {
      final newEquipment = List<String>.from(state.selectedEquipment);
      newEquipment.add(itemKey);
      _updateState(selectedEquipment: newEquipment);
      return true;
    }
    return false;
  }

  void _updateState({
    Map<String, int>? statBonuses,
    List<String>? selectedHeroicAbilities,
    Map<String, int>? selectedSpells,
    Map<String, int>? skillBonuses,
    int? recruitmentPointsBonus,
    List<String>? selectedEquipment,
  }) {
    state = RangerCreationState(
      currentStep: state.currentStep,
      name: state.name,
      notes: state.notes,
      statBonuses: statBonuses ?? state.statBonuses,
      selectedHeroicAbilities:
          selectedHeroicAbilities ?? state.selectedHeroicAbilities,
      selectedSpells: selectedSpells ?? state.selectedSpells,
      skillBonuses: skillBonuses ?? state.skillBonuses,
      recruitmentPointsBonus:
          recruitmentPointsBonus ?? state.recruitmentPointsBonus,
      selectedEquipment: selectedEquipment ?? state.selectedEquipment,
    );
  }

  void reset() {
    state = RangerCreationState();
  }
}

final rangerCreationProvider =
    StateNotifierProvider<RangerCreationNotifier, RangerCreationState>((ref) {
  return RangerCreationNotifier();
});
