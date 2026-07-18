import 'package:drift/drift.dart';
import 'package:rangers_mobile/data/database/app_database.dart';

/// Create a test session companion for insertion.
SessionsCompanion createTestSessionCompanion({
  required int rangerId,
  String scenarioName = 'Test Scenario',
  String missionName = 'Test Mission',
  int turnsPlayed = 0,
  String outcome = '',
  String notes = '',
  int experienceEarned = 0,
  bool isCompleted = false,
}) {
  return SessionsCompanion(
    rangerId: Value(rangerId),
    scenarioName: Value(scenarioName),
    missionName: Value(missionName),
    datePlayed: Value(DateTime.now()),
    turnsPlayed: Value(turnsPlayed),
    outcome: Value(outcome),
    notes: Value(notes),
    experienceEarned: Value(experienceEarned),
    isCompleted: Value(isCompleted),
  );
}

/// Insert a test session and return its auto-generated id.
Future<int> insertTestSession(
  AppDatabase db, {
  required int rangerId,
  String scenarioName = 'Test Scenario',
  bool isCompleted = false,
}) async {
  final companion = createTestSessionCompanion(
    rangerId: rangerId,
    scenarioName: scenarioName,
    isCompleted: isCompleted,
  );
  return await db.into(db.sessions).insert(companion);
}

/// Create a test session event companion.
SessionEventsCompanion createTestSessionEvent({
  required int sessionId,
  required int turnNumber,
  required String phase,
  required String eventType,
  String description = '',
  String figureName = '',
}) {
  return SessionEventsCompanion(
    sessionId: Value(sessionId),
    turnNumber: Value(turnNumber),
    phase: Value(phase),
    eventType: Value(eventType),
    description: Value(description),
    figureName: Value(figureName),
    createdAt: Value(DateTime.now()),
  );
}
