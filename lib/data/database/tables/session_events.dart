import 'package:drift/drift.dart';
import 'sessions.dart';

class SessionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  IntColumn get turnNumber => integer()();
  TextColumn get phase => text()(); // 'ranger', 'creature', 'companion', 'event'
  TextColumn get eventType => text()(); // 'damage', 'heal', 'ability_used', 'spell_cast', 'skill_roll', 'death', 'note'
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get figureName => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
}
