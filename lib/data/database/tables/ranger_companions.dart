import 'package:drift/drift.dart';
import 'rangers.dart';
import 'companion_types.dart';

class RangerCompanions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id)();
  IntColumn get companionTypeId => integer().references(CompanionTypes, #id)();
  TextColumn get customName => text()();
  IntColumn get progressionPoints => integer().withDefault(const Constant(0))();
  BoolColumn get isAlive => boolean().withDefault(const Constant(true))();
  TextColumn get permanentInjuries => text().withDefault(const Constant('[]'))();
  TextColumn get customSkills => text().withDefault(const Constant('{}'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get claimedProgressionRewards => text().withDefault(const Constant('[]'))();
  BoolColumn get hasUsedRecruitmentBonus => boolean().withDefault(const Constant(false))();
  IntColumn get bonusHealth => integer().withDefault(const Constant(0))();
}
