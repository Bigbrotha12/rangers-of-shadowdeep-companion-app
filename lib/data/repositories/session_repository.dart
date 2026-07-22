import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';

class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  // Session CRUD
  Future<int> insertSession(SessionsCompanion session) async {
    return await _db.into(_db.sessions).insert(session);
  }

  Future<Session?> getSessionById(int id) async {
    final query = _db.select(_db.sessions)..where((s) => s.id.equals(id));
    return await query.getSingleOrNull();
  }

  Future<List<Session>> getAllSessions() async {
    final query = _db.select(_db.sessions);
    final results = await query.get();
    results.sort((a, b) => b.datePlayed.compareTo(a.datePlayed));
    return results;
  }

  Future<void> updateSession(int sessionId, SessionsCompanion session) async {
    await (_db.update(_db.sessions)..where((s) => s.id.equals(sessionId))).write(session);
  }

  Future<int> deleteSession(int id) async {
    await (_db.delete(_db.sessionEvents)..where((e) => e.sessionId.equals(id))).go();
    return await (_db.delete(_db.sessions)..where((s) => s.id.equals(id))).go();
  }

  // Session Events CRUD
  Future<int> insertEvent(SessionEventsCompanion event) async {
    return await _db.into(_db.sessionEvents).insert(event);
  }

  Future<List<SessionEvent>> getEventsBySession(int sessionId) async {
    final query = _db.select(_db.sessionEvents)
      ..where((e) => e.sessionId.equals(sessionId));
    final results = await query.get();
    results.sort((a, b) {
      final turnCompare = a.turnNumber.compareTo(b.turnNumber);
      if (turnCompare != 0) return turnCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
    return results;
  }

  // Helper: mark session as complete
  Future<void> completeSession(int sessionId, {String outcome = '', int experienceEarned = 0, String notes = ''}) async {
    await (_db.update(_db.sessions)..where((s) => s.id.equals(sessionId))).write(
      SessionsCompanion(
        isCompleted: const Value(true),
        outcome: Value(outcome),
        experienceEarned: Value(experienceEarned),
        notes: Value(notes),
      ),
    );
  }

  // Helper: update ranger's current health after session
  Future<void> updateRangerCurrentHealth(int rangerId, int currentHealth) async {
    await (_db.update(_db.rangers)..where((r) => r.id.equals(rangerId))).write(
      RangersCompanion(currentHealth: Value(currentHealth)),
    );
  }
}
