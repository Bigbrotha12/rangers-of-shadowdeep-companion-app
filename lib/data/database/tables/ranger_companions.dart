import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/companion_types.dart';
import 'package:rangers_mobile/data/database/tables/rangers.dart';

class RangerCompanions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id)();
  IntColumn get companionTypeId => integer().references(CompanionTypes, #id)();
  TextColumn get customName => text()();
  IntColumn get progressionPoints => integer().withDefault(const Constant(0))();
  BoolColumn get isAlive => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get hasUsedRecruitmentBonus => boolean().withDefault(const Constant(false))();
  IntColumn get bonusHealth => integer().withDefault(const Constant(0))();
}
