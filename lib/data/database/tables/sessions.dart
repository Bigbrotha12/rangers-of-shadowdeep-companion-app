import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/rangers.dart';

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id)();
  TextColumn get scenarioName => text()();
  TextColumn get missionName => text().withDefault(const Constant(''))();
  DateTimeColumn get datePlayed => dateTime()();
  IntColumn get turnsPlayed => integer().withDefault(const Constant(0))();
  TextColumn get outcome => text().withDefault(const Constant(''))(); // 'victory', 'defeat', 'partial'
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get experienceEarned => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}
