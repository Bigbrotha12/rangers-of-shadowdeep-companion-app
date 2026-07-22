import 'package:drift/drift.dart';

class Rangers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get level => integer().withDefault(const Constant(0))();
  IntColumn get experiencePoints => integer().withDefault(const Constant(0))();
  IntColumn get baseRecruitmentPoints => integer().withDefault(const Constant(100))();
  IntColumn get move => integer()();
  IntColumn get fight => integer()();
  IntColumn get shoot => integer()();
  IntColumn get armour => integer()();
  IntColumn get will => integer()();
  IntColumn get health => integer()();
  IntColumn get currentHealth => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}
