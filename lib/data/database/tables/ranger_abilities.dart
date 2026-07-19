import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/rangers.dart';

class RangerAbilities extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id)();
  TextColumn get abilityType => text()(); // 'heroic_ability' or 'spell'
  TextColumn get abilityKey => text()();
  BoolColumn get isUsedThisScenario => boolean().withDefault(const Constant(false))();
}
