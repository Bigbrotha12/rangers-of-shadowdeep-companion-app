import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/equipment.dart';
import 'package:rangers_mobile/data/database/tables/ranger_companions.dart';
import 'package:rangers_mobile/data/database/tables/rangers.dart';

class RangerEquipment extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id)();
  IntColumn get equipmentId => integer().references(Equipment, #id)();
  IntColumn get currentUses => integer().nullable()();
  TextColumn get equippedBy => text().withDefault(const Constant('ranger'))(); // 'ranger', 'companion', or 'pool'
  IntColumn get companionId => integer().references(RangerCompanions, #id).nullable()();
  IntColumn get slotIndex => integer().nullable()(); // 0-5 for equipped, null = inventory
  BoolColumn get isActive => boolean().withDefault(const Constant(true))(); // toggle effects on/off
}
