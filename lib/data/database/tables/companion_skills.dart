import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/ranger_companions.dart';

class CompanionSkills extends Table {
  IntColumn get companionId => integer().references(RangerCompanions, #id, onDelete: KeyAction.cascade)();
  TextColumn get skillKey => text()();
  IntColumn get value => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {companionId, skillKey};
}
