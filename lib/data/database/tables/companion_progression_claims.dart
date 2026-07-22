import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/tables/ranger_companions.dart';

class CompanionProgressionClaims extends Table {
  IntColumn get companionId => integer().references(RangerCompanions, #id, onDelete: KeyAction.cascade)();
  IntColumn get threshold => integer()();
  DateTimeColumn get claimedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {companionId, threshold};
}
