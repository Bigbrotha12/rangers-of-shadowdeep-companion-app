import 'dart:math';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';
import 'package:rangers_mobile/domain/constants/treasure_table.dart';

/* ── Survival Table (d20) ────────────────────────────────────
   Die Roll | Result
   1-2      | Dead
   3-4      | Permanent Injury
   5-6      | Badly Wounded
   7-8      | Close Call
   9+       | Full Recovery
   Rangers may add +1 to the result.
*/
enum SurvivalResult { dead, permanentInjury, badlyWounded, closeCall, fullRecovery }

SurvivalResult rollSurvivalTable(int roll, {bool isRanger = false}) {
  final modified = roll + (isRanger ? 1 : 0);
  if (modified <= 2) return SurvivalResult.dead;
  if (modified <= 4) return SurvivalResult.permanentInjury;
  if (modified <= 6) return SurvivalResult.badlyWounded;
  if (modified <= 8) return SurvivalResult.closeCall;
  return SurvivalResult.fullRecovery;
}

SurvivalResult rollSurvival({bool isRanger = false}) {
  final roll = Random().nextInt(20) + 1;
  return rollSurvivalTable(roll, isRanger: isRanger);
}

/* ── Permanent Injury Table (d20) ────────────────────────────
   Delegates to permanent_injuries.dart rollPermanentInjury()
*/
PermanentInjury rollInjuryTable() {
  final roll = Random().nextInt(20) + 1;
  final key = rollPermanentInjury(roll);
  return permanentInjuries.firstWhere((i) => i.key == key);
}

PermanentInjury rollInjuryTableWithRoll(int d20) {
  final key = rollPermanentInjury(d20);
  return permanentInjuries.firstWhere((i) => i.key == key);
}

/* ── Treasure Roll (d20 main + d20 sub) ──────────────────────
   Delegates to treasure_table.dart resolveTreasureRoll()
*/
({String name, String category}) rollTreasure() {
  final main = Random().nextInt(20) + 1;
  final sub = Random().nextInt(20) + 1;
  return resolveTreasureRoll(main, sub);
}

({String name, String category}) rollTreasureWithRolls(int mainRoll, int subRoll) {
  return resolveTreasureRoll(mainRoll, subRoll);
}

/* ── Experience & Level ──────────────────────────────────────
   Delegates to experience_table.dart
*/
int xpCostForLevel(int currentLevel) => getXpCostForLevel(currentLevel);

LevelBonusType bonusTypeForLevel(int newLevel) => getLevelBonusType(newLevel);

int calculateLevel(int totalXp) {
  int level = 0;
  int remaining = totalXp;
  while (remaining >= getXpCostForLevel(level)) {
    remaining -= getXpCostForLevel(level);
    level++;
    if (level > 100) break;
  }
  return level;
}

/* ── Hero/Companion tracking ──────────────────────────────── */
class SurvivalTarget {
  final int id;
  final String name;
  final bool isRanger;

  SurvivalTarget({required this.id, required this.name, required this.isRanger});
}
