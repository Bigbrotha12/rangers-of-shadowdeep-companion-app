import 'dart:convert';

import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';

int computeStatPenalty(String stat, {
  required List<String> permanentInjuryKeys,
  required List<String> statusEffectKeys,
}) {
  int penalty = 0;

  for (final key in permanentInjuryKeys) {
    final injury = permanentInjuries.where((i) => i.key == key).firstOrNull;
    if (injury != null && injury.affectedStat == stat) {
      penalty += (injury.penalty ?? 0);
    }
  }

  for (final key in statusEffectKeys) {
    final effect = getStatusEffect(key);
    if (effect != null && effect.statModifiers.containsKey(stat)) {
      penalty += effect.statModifiers[stat]!;
    }
  }

  return penalty;
}

List<String> getActiveSpecialRules({
  required List<String> permanentInjuryKeys,
  required List<String> statusEffectKeys,
}) {
  final rules = <String>[];
  for (final key in statusEffectKeys) {
    final effect = getStatusEffect(key);
    if (effect?.specialRule != null) rules.add(effect!.specialRule!);
  }
  if (permanentInjuryKeys.contains('smashed_jaw')) {
    rules.add('max_one_companion_activation');
    rules.add('leadership_minus_3');
  }
  if (permanentInjuryKeys.contains('lost_eye')) {
    rules.add('fight_minus_1_when_target_of_shooting');
  }
  return rules;
}

Map<String, int> computeEquipmentModifiers(
  List<({String effects, bool isActive, int? slotIndex})> items, {
  bool equippedOnly = false,
}) {
  const effectMappings = {
    'armour_bonus': 'armour',
    'fight_bonus': 'fight',
    'fight_penalty': 'fight',
    'shoot_bonus': 'shoot',
    'will_bonus': 'will',
    'will_penalty': 'will',
    'move_bonus': 'move',
    'move_penalty': 'move',
    'damage_modifier': 'damage',
  };

  final stats = <String, int>{};
  for (final item in items) {
    if (!item.isActive) continue;
    if (equippedOnly && item.slotIndex == null) continue;
    try {
      final effects = item.effects;
      if (effects.isEmpty) continue;
      final parsed = Map<String, dynamic>.from(
        const JsonDecoder().convert(effects) as Map,
      );
      for (final entry in effectMappings.entries) {
        final mod = parsed[entry.key] as int?;
        if (mod != null) {
          stats.update(entry.value, (v) => v + mod, ifAbsent: () => mod);
        }
      }
    } on FormatException catch (_) {
      // Graceful degradation: invalid effects JSON treated as empty
    }
  }
  return stats;
}

Map<String, int> computeEquipmentModifiersFromWithName(
  List<Object> items, {
  bool equippedOnly = false,
}) {
  return computeEquipmentModifiers(
    items.map((item) {
      final e = item as dynamic;
      return (effects: e.effects as String, isActive: e.isActive as bool, slotIndex: e.slotIndex as int?);
    }).toList(),
    equippedOnly: equippedOnly,
  );
}

bool hasMaxOneAction(List<String> statusEffectKeys) {
  return statusEffectKeys.contains('poisoned');
}
