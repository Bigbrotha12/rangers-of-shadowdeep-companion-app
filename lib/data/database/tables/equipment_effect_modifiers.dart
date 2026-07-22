import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/equipment.dart';

class EquipmentEffectModifiers extends Table {
  IntColumn get equipmentId => integer().references(Equipment, #id)();
  TextColumn get statKey => text()();
  IntColumn get modifier => integer()();

  @override
  Set<Column> get primaryKey => {equipmentId, statKey};
}
