import 'package:drift/drift.dart';

class CompanionTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get typeKey => text().unique()();
  TextColumn get name => text()();
  IntColumn get rpCost => integer()();
  IntColumn get move => integer()();
  IntColumn get fight => integer()();
  IntColumn get shoot => integer()();
  IntColumn get armour => integer()();
  IntColumn get will => integer()();
  IntColumn get health => integer()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get isAnimal => boolean().withDefault(const Constant(false))();
}
