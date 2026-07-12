import 'package:drift/drift.dart';
import 'rangers.dart';

class RangerSkills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rangerId => integer().references(Rangers, #id)();
  TextColumn get skillKey => text()();
  IntColumn get value => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [{rangerId, skillKey}];
}
