import 'package:drift/drift.dart';
import 'rangers.dart';
import 'ranger_companions.dart';

class Injuries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id).nullable()();
  IntColumn get companionId => integer().references(RangerCompanions, #id).nullable()();
  TextColumn get injuryKey => text()();
  IntColumn get timesReceived => integer().withDefault(const Constant(1))();
  DateTimeColumn get receivedAt => dateTime()();
}
