import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/ranger_companions.dart';
import 'package:rangers_mobile/data/database/tables/rangers.dart';

class Injuries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id).nullable()();
  IntColumn get companionId => integer().references(RangerCompanions, #id).nullable()();
  TextColumn get injuryKey => text()();
  IntColumn get timesReceived => integer().withDefault(const Constant(1))();
  DateTimeColumn get receivedAt => dateTime()();
}
