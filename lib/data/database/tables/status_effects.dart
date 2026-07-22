import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/ranger_companions.dart';
import 'package:rangers_mobile/data/database/tables/rangers.dart';

class StatusEffects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id, onDelete: KeyAction.cascade).nullable()();
  IntColumn get companionId => integer().references(RangerCompanions, #id, onDelete: KeyAction.cascade).nullable()();
  TextColumn get statusEffectKey => text()();
  // Invariant: at least one of rangerId or companionId must be non-null
  // Unique enforcement via partial indexes in migration
}
