import '../constants/permanent_injuries.dart';
import '../constants/status_effects.dart';

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

bool hasMaxOneAction(List<String> statusEffectKeys) {
  return statusEffectKeys.contains('poisoned');
}
