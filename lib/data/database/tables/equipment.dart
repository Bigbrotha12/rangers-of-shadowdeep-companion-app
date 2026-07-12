import 'package:drift/drift.dart';

class Equipment extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemKey => text().unique()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // basic_weapon, basic_armour, basic_gear, magic_weapon, magic_armour, magic_item, herb_potion
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get effects => text().withDefault(const Constant('{}'))();
  BoolColumn get hasUses => boolean().withDefault(const Constant(false))();
  IntColumn get maxUses => integer().nullable()();
}
