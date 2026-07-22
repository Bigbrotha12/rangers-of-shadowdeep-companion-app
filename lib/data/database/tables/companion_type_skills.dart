import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/companion_types.dart';

class CompanionTypeSkills extends Table {
  IntColumn get companionTypeId => integer().references(CompanionTypes, #id)();
  TextColumn get skillKey => text()();
  IntColumn get value => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {companionTypeId, skillKey};
}
