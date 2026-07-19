import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/session_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart' show companionTypeKeyFromId, getCompanionType;
import 'package:rangers_mobile/domain/constants/status_effects.dart' show getStatusEffect;

// Session phases
enum SessionPhase { ranger, creature, companion, event }

// Creature tracking
class CreatureData {
  final int id;
  final String name;
  final int currentHealth;
  final int maxHealth;
  final bool isDead;

  const CreatureData({
    required this.id,
    required this.name,
    required this.currentHealth,
    required this.maxHealth,
    this.isDead = false,
  });

  CreatureData copyWith({
    int? id,
    String? name,
    int? currentHealth,
    int? maxHealth,
    bool? isDead,
  }) {
    return CreatureData(
      id: id ?? this.id,
      name: name ?? this.name,
      currentHealth: currentHealth ?? this.currentHealth,
      maxHealth: maxHealth ?? this.maxHealth,
      isDead: isDead ?? this.isDead,
    );
  }
}

// Party member state (ranger + companions)
class PartyMemberState {
  final int id;
  final String name;
  final String type; // 'ranger' or 'companion'
  final int currentHealth;
  final int maxHealth;
  final bool isDead;
  final bool hasActed;
  final bool carryingTreasure;
  final Map<String, bool> usedAbilities; // abilityKey → used this scenario
  final List<String> statusEffects;

  const PartyMemberState({
    required this.id,
    required this.name,
    required this.type,
    required this.currentHealth,
    required this.maxHealth,
    this.isDead = false,
    this.hasActed = false,
    this.carryingTreasure = false,
    this.usedAbilities = const {},
    this.statusEffects = const [],
  });

  PartyMemberState copyWith({
    int? id,
    String? name,
    String? type,
    int? currentHealth,
    int? maxHealth,
    bool? isDead,
    bool? hasActed,
    bool? carryingTreasure,
    Map<String, bool>? usedAbilities,
    List<String>? statusEffects,
  }) {
    return PartyMemberState(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentHealth: currentHealth ?? this.currentHealth,
      maxHealth: maxHealth ?? this.maxHealth,
      isDead: isDead ?? this.isDead,
      hasActed: hasActed ?? this.hasActed,
      carryingTreasure: carryingTreasure ?? this.carryingTreasure,
      usedAbilities: usedAbilities ?? this.usedAbilities,
      statusEffects: statusEffects ?? this.statusEffects,
    );
  }
}

// Session event log entry
class EventLogEntry {
  final int? id;
  final int turnNumber;
  final SessionPhase phase;
  final String eventType;
  final String description;
  final String figureName;
  final DateTime createdAt;

  const EventLogEntry({
    this.id,
    required this.turnNumber,
    required this.phase,
    required this.eventType,
    this.description = '',
    this.figureName = '',
    required this.createdAt,
  });
}

// Full active session state
class ActiveSessionState {
  final int? sessionId;
  final int rangerId;
  final String scenarioName;
  final String missionName;
  final int currentTurn;
  final SessionPhase currentPhase;
  final List<PartyMemberState> party;
  final List<CreatureData> creatures;
  final List<EventLogEntry> eventLog;
  final bool isCompleted;

  const ActiveSessionState({
    this.sessionId,
    required this.rangerId,
    this.scenarioName = '',
    this.missionName = '',
    this.currentTurn = 1,
    this.currentPhase = SessionPhase.ranger,
    this.party = const [],
    this.creatures = const [],
    this.eventLog = const [],
    this.isCompleted = false,
  });

  int get nextCreatureId => creatures.isEmpty ? 1 : (creatures.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1);

  ActiveSessionState copyWith({
    int? sessionId,
    int? rangerId,
    String? scenarioName,
    String? missionName,
    int? currentTurn,
    SessionPhase? currentPhase,
    List<PartyMemberState>? party,
    List<CreatureData>? creatures,
    List<EventLogEntry>? eventLog,
    bool? isCompleted,
  }) {
    return ActiveSessionState(
      sessionId: sessionId ?? this.sessionId,
      rangerId: rangerId ?? this.rangerId,
      scenarioName: scenarioName ?? this.scenarioName,
      missionName: missionName ?? this.missionName,
      currentTurn: currentTurn ?? this.currentTurn,
      currentPhase: currentPhase ?? this.currentPhase,
      party: party ?? this.party,
      creatures: creatures ?? this.creatures,
      eventLog: eventLog ?? this.eventLog,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// Active Session Notifier
class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  ActiveSessionNotifier(this._ref) : super(const ActiveSessionState(rangerId: 0));

  final Ref _ref;

  // Initialize a new session
  Future<void> startSession({
    required int rangerId,
    required String scenarioName,
    String missionName = '',
    required List<PartyMemberState> initialParty,
  }) async {
    final repo = _ref.read(sessionRepositoryProvider);
    
    // Insert session record
    final sessionId = await repo.insertSession(SessionsCompanion(
      rangerId: Value(rangerId),
      scenarioName: Value(scenarioName),
      missionName: Value(missionName),
      datePlayed: Value(DateTime.now()),
      turnsPlayed: const Value(1),
      isCompleted: const Value(false),
    ));

    // Build initial party
    final party = initialParty.map((p) => p.copyWith(hasActed: false)).toList();

    // Create initial event
    final now = DateTime.now();
    await repo.insertEvent(SessionEventsCompanion(
      sessionId: Value(sessionId),
      turnNumber: const Value(1),
      phase: const Value('event'),
      eventType: const Value('note'),
      description: Value('Mission started: $scenarioName${missionName.isNotEmpty ? ' - $missionName' : ''}'),
      figureName: const Value(''),
      createdAt: Value(now),
    ));

    // Load the event
    final events = await repo.getEventsBySession(sessionId);

    state = ActiveSessionState(
      sessionId: sessionId,
      rangerId: rangerId,
      scenarioName: scenarioName,
      missionName: missionName,
      party: party,
      creatures: [],
      eventLog: events.map((e) => EventLogEntry(
        id: e.id,
        turnNumber: e.turnNumber,
        phase: SessionPhase.values.firstWhere((p) => p.name == e.phase, orElse: () => SessionPhase.event),
        eventType: e.eventType,
        description: e.description,
        figureName: e.figureName,
        createdAt: e.createdAt,
      )).toList(),
    );
  }

  // Load an existing session from DB
  Future<void> loadSession(int sessionId) async {
    final repo = _ref.read(sessionRepositoryProvider);
    final session = await repo.getSessionById(sessionId);
    if (session == null) return;

    // Load ranger data for party
    final rangerRepo = _ref.read(rangerRepositoryProvider);
    final ranger = await rangerRepo.getRangerById(session.rangerId);
    final companions = await _ref.read(companionRepositoryProvider).getCompanionsByRanger(session.rangerId, isActive: true);

    // Build party from ranger + companions
    final party = <PartyMemberState>[];
    if (ranger != null) {
      final rangerEffects = List<String>.from(
        jsonDecode(ranger.statusEffects) as List? ?? [],
      );
      party.add(PartyMemberState(
        id: ranger.id,
        name: ranger.name,
        type: 'ranger',
        currentHealth: ranger.currentHealth,
        maxHealth: ranger.health,
        statusEffects: rangerEffects,
      ));
    }
    for (final comp in companions) {
      final typeKey = companionTypeKeyFromId(comp.companionTypeId);
      final type = getCompanionType(typeKey);
      final baseHealth = type?.health ?? 10;
      final compEffects = List<String>.from(
        jsonDecode(comp.statusEffects) as List? ?? [],
      );
      party.add(PartyMemberState(
        id: comp.id,
        name: comp.customName,
        type: 'companion',
        currentHealth: baseHealth + comp.bonusHealth,
        maxHealth: baseHealth + comp.bonusHealth,
        statusEffects: compEffects,
      ));
    }

    // Load events
    final events = await repo.getEventsBySession(sessionId);

    state = ActiveSessionState(
      sessionId: sessionId,
      rangerId: session.rangerId,
      scenarioName: session.scenarioName,
      missionName: session.missionName,
      currentTurn: session.turnsPlayed,
      party: party,
      creatures: [],
      eventLog: events.map((e) => EventLogEntry(
        id: e.id,
        turnNumber: e.turnNumber,
        phase: SessionPhase.values.firstWhere((p) => p.name == e.phase, orElse: () => SessionPhase.event),
        eventType: e.eventType,
        description: e.description,
        figureName: e.figureName,
        createdAt: e.createdAt,
      )).toList(),
      isCompleted: session.isCompleted,
    );
  }

  // Advance to next phase
  void nextPhase() {
    const phases = SessionPhase.values;
    final nextIndex = (state.currentPhase.index + 1) % phases.length;
    
    if (nextIndex == 0) {
      // Back to ranger phase = new turn
      state = state.copyWith(
        currentTurn: state.currentTurn + 1,
        currentPhase: SessionPhase.ranger,
        party: state.party.map((p) => p.copyWith(hasActed: false)).toList(),
      );
    } else {
      state = state.copyWith(currentPhase: phases[nextIndex]);
    }
  }

  // Jump to a specific phase
  void setPhase(SessionPhase phase) {
    state = state.copyWith(currentPhase: phase);
  }

  // Update party member health
  Future<void> updatePartyHealth(int memberId, String memberType, int delta) async {
    final updatedParty = state.party.map((member) {
      if (member.id == memberId && member.type == memberType) {
        final newHealth = (member.currentHealth + delta).clamp(0, member.maxHealth);
        return member.copyWith(
          currentHealth: newHealth,
          isDead: newHealth <= 0,
          carryingTreasure: member.carryingTreasure && newHealth > 0,
        );
      }
      return member;
    }).toList();

    state = state.copyWith(party: updatedParty);

    // Log the event
    final member = updatedParty.firstWhere((m) => m.id == memberId && m.type == memberType);
    final eventType = delta > 0 ? 'heal' : 'damage';
    final description = delta > 0
        ? '${member.name} healed for ${delta.abs()} HP'
        : '${member.name} took ${delta.abs()} damage';
    
    await _logEvent(eventType, description, member.name);
  }

  // Mark party member as having acted
  void markPartyActed(int memberId, String memberType) {
    state = state.copyWith(
      party: state.party.map((m) => m.id == memberId && m.type == memberType ? m.copyWith(hasActed: true) : m).toList(),
    );
  }

  // Toggle whether a heroic ability has been used this scenario
  void toggleAbilityUsed(int memberId, String memberType, String abilityKey) {
    state = state.copyWith(
      party: state.party.map((m) {
        if (m.id == memberId && m.type == memberType) {
          final updated = Map<String, bool>.from(m.usedAbilities);
          updated[abilityKey] = !(updated[abilityKey] ?? false);
          return m.copyWith(usedAbilities: updated);
        }
        return m;
      }).toList(),
    );
  }

  // Update status effects for a party member
  void updateMemberStatusEffects(int memberId, String memberType, List<String> effects) {
    state = state.copyWith(
      party: state.party.map((m) {
        if (m.id == memberId && m.type == memberType) {
          return m.copyWith(statusEffects: effects);
        }
        return m;
      }).toList(),
    );
  }

  // Apply a status effect to a party member (no duplicate)
  Future<void> applyStatusEffectToMember(int memberId, String memberType, String effectKey) async {
    final member = state.party.where(
      (m) => m.id == memberId && m.type == memberType,
    ).firstOrNull;
    if (member == null) return;
    if (member.statusEffects.contains(effectKey)) return;

    final effectName = _getStatusEffectName(effectKey);
    updateMemberStatusEffects(memberId, memberType, [...member.statusEffects, effectKey]);
    await _logEvent('status_effect', 'Applied $effectName to ${member.name}', member.name);
  }

  // Remove a status effect from a party member
  Future<void> removeStatusEffectFromMember(int memberId, String memberType, String effectKey) async {
    final member = state.party.where(
      (m) => m.id == memberId && m.type == memberType,
    ).firstOrNull;
    if (member == null) return;

    final effectName = _getStatusEffectName(effectKey);
    updateMemberStatusEffects(memberId, memberType,
      member.statusEffects.where((k) => k != effectKey).toList(),
    );
    await _logEvent('status_effect', 'Removed $effectName from ${member.name}', member.name);
  }

  String _getStatusEffectName(String key) {
    // Imported lazily via domain constants — simple name map
    const names = {
      'poisoned': 'Poisoned',
      'diseased': 'Diseased',
      'hunger_1': 'Hunger/Thirst (1)',
      'hunger_2': 'Hunger/Thirst (2)',
      'hunger_3': 'Hunger/Thirst (3)',
      'exhausted': 'Exhausted',
      'blessed': 'Blessed',
      'cursed': 'Cursed',
    };
    return names[key] ?? key.replaceAll('_', ' ');
  }

  // Toggle whether a party member is carrying a treasure
  void toggleCarryingTreasure(int memberId, String memberType) {
    state = state.copyWith(
      party: state.party.map((m) =>
        m.id == memberId && m.type == memberType
          ? m.copyWith(carryingTreasure: !m.carryingTreasure)
          : m
      ).toList(),
    );
  }

  // Add a creature
  void addCreature(String name, int health) {
    final creature = CreatureData(
      id: state.nextCreatureId,
      name: name,
      currentHealth: health,
      maxHealth: health,
    );
    state = state.copyWith(creatures: [...state.creatures, creature]);
  }

  // Update creature health
  Future<void> updateCreatureHealth(int creatureId, int delta) async {
    final updatedCreatures = state.creatures.map((c) {
      if (c.id == creatureId) {
        final newHealth = (c.currentHealth + delta).clamp(0, c.maxHealth);
        return c.copyWith(
          currentHealth: newHealth,
          isDead: newHealth <= 0,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(creatures: updatedCreatures);

    // Log the event
    final creature = updatedCreatures.firstWhere((c) => c.id == creatureId);
    final eventType = delta > 0 ? 'heal' : 'damage';
    final description = delta > 0
        ? '${creature.name} healed for ${delta.abs()} HP'
        : '${creature.name} took ${delta.abs()} damage';
    
    await _logEvent(eventType, description, creature.name);
  }

  // Remove a creature
  void removeCreature(int creatureId) {
    state = state.copyWith(
      creatures: state.creatures.where((c) => c.id != creatureId).toList(),
    );
  }

  // Add a custom note to the log
  Future<void> addNote(String note) async {
    await _logEvent('note', note, '');
  }

  // Log an event to DB and state
  Future<void> _logEvent(String eventType, String description, String figureName) async {
    if (state.sessionId == null) return;

    final repo = _ref.read(sessionRepositoryProvider);
    final now = DateTime.now();

    final event = SessionEventsCompanion(
      sessionId: Value(state.sessionId!),
      turnNumber: Value(state.currentTurn),
      phase: Value(state.currentPhase.name),
      eventType: Value(eventType),
      description: Value(description),
      figureName: Value(figureName),
      createdAt: Value(now),
    );

    final eventId = await repo.insertEvent(event);

    final logEntry = EventLogEntry(
      id: eventId,
      turnNumber: state.currentTurn,
      phase: state.currentPhase,
      eventType: eventType,
      description: description,
      figureName: figureName,
      createdAt: now,
    );

    state = state.copyWith(eventLog: [...state.eventLog, logEntry]);
  }

  // Save current state and prepare for pause
  Future<void> pauseSession() async {
    if (state.sessionId == null) return;
    final repo = _ref.read(sessionRepositoryProvider);
    final rangerMember = state.party.where((p) => p.type == 'ranger').firstOrNull;
    if (rangerMember != null) {
      await repo.updateRangerCurrentHealth(state.rangerId, rangerMember.currentHealth);
    }
  }

  // End session
  Future<void> endSession({String outcome = '', int experienceEarned = 0, String notes = ''}) async {
    if (state.sessionId == null) return;

    final repo = _ref.read(sessionRepositoryProvider);

    // Save treasure count from carrying members
    final treasureCount = state.party.where((m) => m.carryingTreasure).length;
    final sessionNotes = treasureCount > 0 ? 'Treasure Found: $treasureCount' : notes;

    await repo.completeSession(
      state.sessionId!,
      outcome: outcome,
      experienceEarned: experienceEarned,
      notes: sessionNotes,
    );

    // Update ranger's current health from session
    final rangerMember = state.party.where((p) => p.type == 'ranger').firstOrNull;
    if (rangerMember != null) {
      await repo.updateRangerCurrentHealth(state.rangerId, rangerMember.currentHealth);
    }

    // Persist non-temporary status effects (e.g. hunger carries forward)
    for (final member in state.party) {
      final persistentEffects = member.statusEffects.where((key) {
        final effect = getStatusEffect(key);
        return effect != null && !effect.isTemporary;
      }).toList();

      if (member.type == 'ranger') {
        await _ref.read(rangerRepositoryProvider).updateRangerFields(
          member.id,
          RangersCompanion(
            statusEffects: Value(jsonEncode(persistentEffects)),
          ),
        );
      } else {
        final existing = await _ref.read(companionRepositoryProvider).getCompanionById(member.id);
        if (existing != null) {
          final currentDbEffects = List<String>.from(
            jsonDecode(existing.statusEffects) as List? ?? [],
          );
          final merged = <String>{...currentDbEffects, ...persistentEffects}.toList();
          await _ref.read(companionRepositoryProvider).updateCompanion(
            RangerCompanionsCompanion(
              id: Value(member.id),
              statusEffects: Value(jsonEncode(merged)),
            ),
          );
        }
      }
    }

    state = state.copyWith(isCompleted: true);

    // Add final event
    await _logEvent('note', 'Mission ended: $outcome', '');
  }
}

// Provider for the active session
final activeSessionProvider = StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState>((ref) {
  return ActiveSessionNotifier(ref);
});

// Provider for session history
final sessionHistoryProvider = FutureProvider<List<Session>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  return await repo.getAllSessions();
});

// Provider for a specific session's details
final sessionDetailProvider = FutureProvider.family<Session?, int>((ref, sessionId) async {
  final repo = ref.watch(sessionRepositoryProvider);
  return await repo.getSessionById(sessionId);
});

Future<void> deleteSession(WidgetRef ref, int sessionId) async {
  final repo = ref.read(sessionRepositoryProvider);
  await repo.deleteSession(sessionId);
  ref.invalidate(sessionHistoryProvider);
}
