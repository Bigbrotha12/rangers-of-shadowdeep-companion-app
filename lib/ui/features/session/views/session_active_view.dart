import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../view_models/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/ranger_repository_provider.dart';
import '../../rangers/view_models/ranger_detail_provider.dart';
import '../../../../domain/constants/companion_types.dart';
import '../../../../domain/constants/heroic_abilities.dart';
import '../../../../domain/constants/spells.dart';
import '../../../../domain/constants/skills.dart';
import '../../../../domain/constants/status_effects.dart';
import '../../../../domain/constants/permanent_injuries.dart';
import '../../../../domain/services/stat_calculation_service.dart';

class SessionActiveView extends ConsumerStatefulWidget {
  const SessionActiveView({required this.sessionId, super.key});

  final int sessionId;

  @override
  ConsumerState<SessionActiveView> createState() => _SessionActiveViewState();
}

class _SessionActiveViewState extends ConsumerState<SessionActiveView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeSessionProvider.notifier).loadSession(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);

    if (session.sessionId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(session.scenarioName.isNotEmpty ? session.scenarioName : 'Active Session'),
        actions: [
          // Dice roller
          IconButton(
            icon: const Icon(Icons.casino),
            onPressed: () => _showDiceRoller(context),
            tooltip: 'Roll Dice',
          ),
          // Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'pause') _pauseSession(context, ref);
              if (value == 'end') _showEndSessionDialog(context, ref);
              if (value == 'add_creature') _showAddCreatureDialog(context, ref);
              if (value == 'add_note') _showAddNoteDialog(context, ref);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'add_creature', child: Text('Add Creature')),
              const PopupMenuItem(value: 'add_note', child: Text('Add Note')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'pause', child: Text('Pause Session')),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'end',
                child: Text('End Session', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Turn Tracker
          _TurnTracker(session: session),

          // Phase Indicator
          _PhaseIndicator(
            currentPhase: session.currentPhase,
            onNextPhase: () => ref.read(activeSessionProvider.notifier).nextPhase(),
          ),

          const Divider(height: 1),

          // Main content - scrollable
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Party Panel
                _PartyPanel(session: session),
                const SizedBox(height: 16),

                // Creature Panel
                _CreaturePanel(session: session),
                const SizedBox(height: 16),

                // Event Log
                _EventLog(session: session),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDiceRoller(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _DiceRollerSheet(),
    );
  }

  Future<void> _pauseSession(BuildContext context, WidgetRef ref) async {
    await ref.read(activeSessionProvider.notifier).pauseSession();
    if (!context.mounted) return;
    context.go('/session');
  }

  void _showAddCreatureDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final healthController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Creature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Creature Name',
                hintText: 'e.g., Goblin 1',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: healthController,
              decoration: const InputDecoration(
                labelText: 'Health Points',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final health = int.tryParse(healthController.text) ?? 10;
              if (name.isNotEmpty) {
                ref.read(activeSessionProvider.notifier).addCreature(name, health);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter a note...',
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final note = noteController.text.trim();
              if (note.isNotEmpty) {
                ref.read(activeSessionProvider.notifier).addNote(note);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context, WidgetRef ref) {
    final xpController = TextEditingController(text: '0');
    String outcome = 'victory';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('End Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How did the mission go?'),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'victory', label: Text('Victory')),
                  ButtonSegment(value: 'partial', label: Text('Partial')),
                  ButtonSegment(value: 'defeat', label: Text('Defeat')),
                ],
                selectedIcon: const SizedBox.shrink(),
                selected: {outcome},
                onSelectionChanged: (selection) {
                  setDialogState(() => outcome = selection.first);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: xpController,
                decoration: const InputDecoration(
                  labelText: 'Experience Earned',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final xp = int.tryParse(xpController.text) ?? 0;
                final sessionNotifier = ref.read(activeSessionProvider.notifier);
                await sessionNotifier.endSession(
                  outcome: outcome,
                  experienceEarned: xp,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  final sessionId = ref.read(activeSessionProvider).sessionId;
                  context.go('/session/post-game/$sessionId');
                }
              },
              child: const Text('End Session'),
            ),
          ],
        ),
      ),
    );
  }
}

// Turn Tracker
class _TurnTracker extends StatelessWidget {
  const _TurnTracker({required this.session});

  final ActiveSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.turn_right, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Turn ${session.currentTurn}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (session.missionName.isNotEmpty)
            Text(
              session.missionName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

// Phase Indicator
class _PhaseIndicator extends StatelessWidget {
  const _PhaseIndicator({
    required this.currentPhase,
    required this.onNextPhase,
  });

  final SessionPhase currentPhase;
  final VoidCallback onNextPhase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const phases = SessionPhase.values;
    final phaseNames = ['Ranger', 'Creature', 'Companion', 'Event'];
    final phaseIcons = [Icons.person, Icons.pets, Icons.group, Icons.event];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < phases.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _PhaseChip(
                  label: phaseNames[i],
                  icon: phaseIcons[i],
                  isActive: phases[i] == currentPhase,
                  isPast: phases[i].index < currentPhase.index,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: onNextPhase,
              child: const Text('Next Phase'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isPast,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : isPast
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive
                ? theme.colorScheme.onPrimary
                : isPast
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : isPast
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Party Panel
class _PartyPanel extends StatelessWidget {
  const _PartyPanel({required this.session});

  final ActiveSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Party',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (session.party.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No party members',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...session.party.map((member) => _PartyMemberCard(
            member: member,
            rangerId: session.rangerId,
          )),
      ],
    );
  }
}

class _PartyMemberCard extends ConsumerStatefulWidget {
  const _PartyMemberCard({required this.member, required this.rangerId});

  final PartyMemberState member;
  final int rangerId;

  @override
  ConsumerState<_PartyMemberCard> createState() => _PartyMemberCardState();
}

class _PartyMemberCardState extends ConsumerState<_PartyMemberCard> {
  final TextEditingController _deltaController = TextEditingController(text: '1');
  bool _isExpanded = false;

  @override
  void dispose() {
    _deltaController.dispose();
    super.dispose();
  }

  int get _delta => int.tryParse(_deltaController.text) ?? 1;

  Future<void> _toggleItemActive(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    await repo.updateRangerEquipment(RangerEquipmentCompanion(
      id: Value(item.id),
      isActive: Value(!item.isActive),
    ));
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _useItem(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    await repo.useEquipmentCharge(item.id);
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _confirmAndUseItem(BuildContext context, RangerEquipmentData item, String itemName) async {
    final remaining = item.currentUses ?? 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Use Item Charge'),
        content: Text(
          remaining <= 1
              ? 'Use $itemName? This will consume the item.'
              : 'Use one charge of $itemName?\n\n$remaining charges remaining.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Use'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _useItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = widget.member;
    final rangerAsync = ref.watch(rangerDetailProvider(widget.rangerId));

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) return const SizedBox.shrink();

        // ── Equipment filtered for this member ──
        final equippedBy = member.type == 'ranger' ? 'ranger' : member.id.toString();
        final memberEquip = ranger.equipment
          .where((e) => e.slotIndex != null)
          .where((e) => e.equipment.equippedBy == equippedBy)
          .toList();

        // ── Stats computation ──
        final equipMods = _computeEquipMods(memberEquip);
        StatRow stats;

        // Compute combined penalties from both permanent injuries (parsed from notes)
        // and active status effects
        final rangerInjuryKeys = (ranger.ranger.notes.contains('[Injury]'))
            ? RegExp(r'\[Injury\]\s*(\w+(?:_\w+)*)')
                .allMatches(ranger.ranger.notes)
                .map((m) => m.group(1)!)
                .toList()
            : <String>[];

        if (member.type == 'ranger') {
          final seMove = computeStatPenalty('move',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          final seFight = computeStatPenalty('fight',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          final seShoot = computeStatPenalty('shoot',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          final seWill = computeStatPenalty('will',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          final seHealth = computeStatPenalty('health',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          stats = StatRow(
            move: ranger.ranger.move + seMove + (equipMods['move'] ?? 0),
            fight: ranger.ranger.fight + seFight + (equipMods['fight'] ?? 0),
            shoot: ranger.ranger.shoot + seShoot + (equipMods['shoot'] ?? 0),
            armour: ranger.ranger.armour + (equipMods['armour'] ?? 0),
            will: ranger.ranger.will + seWill + (equipMods['will'] ?? 0),
            health: member.maxHealth + seHealth,
            damage: equipMods['damage'],
          );
        } else {
          final companion = ranger.companions.where((c) => c.id == member.id).firstOrNull;
          if (companion != null) {
            final typeKey = companionTypeKeyFromId(companion.companionTypeId);
            final type = getCompanionType(typeKey);
            final customSkills = Map<String, int>.from(
              const JsonDecoder().convert(companion.customSkills) as Map? ?? {},
            );
            final injuries = List<String>.from(
              jsonDecode(companion.permanentInjuries) as List? ?? [],
            );
            final statusEffectPenaltyMove = computeStatPenalty('move',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );
            final statusEffectPenaltyFight = computeStatPenalty('fight',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );
            final statusEffectPenaltyShoot = computeStatPenalty('shoot',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );
            final statusEffectPenaltyWill = computeStatPenalty('will',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );
            final statusEffectPenaltyHealth = computeStatPenalty('health',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );

            stats = StatRow(
              move: (type?.move ?? 6) + (customSkills['move'] ?? 0) + statusEffectPenaltyMove + (equipMods['move'] ?? 0),
              fight: (type?.fight ?? 0) + (customSkills['fight'] ?? 0) + statusEffectPenaltyFight + (equipMods['fight'] ?? 0),
              shoot: (type?.shoot ?? 0) + (customSkills['shoot'] ?? 0) + statusEffectPenaltyShoot + (equipMods['shoot'] ?? 0),
              armour: (type?.armour ?? 10) + (equipMods['armour'] ?? 0),
              will: (type?.will ?? 0) + (customSkills['will'] ?? 0) + statusEffectPenaltyWill + (equipMods['will'] ?? 0),
              health: (type?.health ?? 10) + statusEffectPenaltyHealth + companion.bonusHealth,
              damage: equipMods['damage'],
            );
          } else {
            stats = StatRow(
              move: 6, fight: 0, shoot: 0, armour: 10, will: 0, health: member.maxHealth,
            );
          }
        }

        // ── Abilities, spells, and skills for expanded view ──
        List<_NamedAbility> memberHeroicAbilities = [];
        List<_NamedAbility> memberSpells = [];
        List<_NamedSkill> memberSkills = [];

        if (member.type == 'ranger') {
          memberHeroicAbilities = ranger.heroicAbilities.map((a) {
            final data = heroicAbilities.firstWhere(
              (h) => h.key == a.abilityKey,
              orElse: () => heroicAbilities.first,
            );
            return _NamedAbility(key: a.abilityKey, name: data.name, description: data.description);
          }).toList();

          memberSpells = ranger.spells.map((s) {
            final data = spells.firstWhere(
              (sp) => sp.key == s.abilityKey,
              orElse: () => spells.first,
            );
            return _NamedAbility(key: s.abilityKey, name: data.name, description: data.description);
          }).toList();

          memberSkills = ranger.skillBonuses
            .where((s) => s.value > 0)
            .map((s) {
              final skill = skills.firstWhere(
                (sk) => sk.key == s.skillKey,
                orElse: () => skills.first,
              );
              return _NamedSkill(key: s.skillKey, name: skill.name, value: s.value);
            }).toList();
        } else {
          final companion = ranger.companions.where((c) => c.id == member.id).firstOrNull;
          if (companion != null) {
            final typeKey = companionTypeKeyFromId(companion.companionTypeId);
            final type = getCompanionType(typeKey);

            final heroicKeys = List<String>.from(
              const JsonDecoder().convert(companion.heroicAbilityKeys) as List? ?? [],
            );
            final spellKeys = List<String>.from(
              const JsonDecoder().convert(companion.spellKeys) as List? ?? [],
            );

            memberHeroicAbilities = heroicKeys.map((key) {
              final data = heroicAbilities.firstWhere(
                (h) => h.key == key,
                orElse: () => heroicAbilities.first,
              );
              return _NamedAbility(key: key, name: data.name, description: data.description);
            }).toList();

            memberSpells = spellKeys.map((key) {
              final data = spells.firstWhere(
                (sp) => sp.key == key,
                orElse: () => spells.first,
              );
              return _NamedAbility(key: key, name: data.name, description: data.description);
            }).toList();

            final companionSkillValues = <String, int>{};
            if (type != null) companionSkillValues.addAll(type.baseSkills);
            final customSkills = Map<String, int>.from(
              const JsonDecoder().convert(companion.customSkills) as Map? ?? {},
            );
            for (final e in customSkills.entries) {
              companionSkillValues[e.key] = (companionSkillValues[e.key] ?? 0) + e.value;
            }

            memberSkills = companionSkillValues.entries
              .where((e) => e.value > 0)
              .map((e) {
                final skill = skills.firstWhere(
                  (sk) => sk.key == e.key,
                  orElse: () => skills.first,
                );
                return _NamedSkill(key: e.key, name: skill.name, value: e.value);
              }).toList();
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: member.isDead
              ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
              : member.hasActed
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: member.isDead ? null : () => setState(() => _isExpanded = !_isExpanded),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wideEnough = constraints.maxWidth >= 480;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ──
                      Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            backgroundColor: member.isDead
                                ? theme.colorScheme.error
                                : member.type == 'ranger'
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.secondaryContainer,
                            child: Icon(
                              member.isDead ? Icons.close : member.type == 'ranger' ? Icons.person : Icons.pets,
                              color: member.isDead
                                  ? theme.colorScheme.onError
                                  : member.type == 'ranger'
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name and HP
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: member.isDead ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                Text(
                                  'HP: ${member.currentHealth}/${member.maxHealth}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: member.currentHealth <= 0
                                        ? theme.colorScheme.error
                                        : member.currentHealth <= member.maxHealth ~/ 3
                                            ? statusOrange(theme)
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Treasure indicator (visible in collapsed state)
                          if (member.carryingTreasure) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.diamond, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                          ],

                          // Undo death
                          if (member.isDead)
                            TextButton.icon(
                              icon: const Icon(Icons.restore, size: 18),
                              label: const Text('Restore'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => ref.read(activeSessionProvider.notifier).updatePartyHealth(member.id, member.type, member.maxHealth),
                            ),

                          // Stats table (inline in header when wide enough)
                          if (wideEnough && !member.isDead) ...[
                            const SizedBox(width: 8),
                            _StatTable(stats: stats),
                            const SizedBox(width: 8),
                          ],

                          // HP Controls
                          if (!member.isDead) ...[
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
                              onPressed: () => ref.read(activeSessionProvider.notifier).updatePartyHealth(member.id, member.type, -_delta),
                              iconSize: 28,
                            ),
                            SizedBox(
                              width: 44,
                              child: TextField(
                                controller: _deltaController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: statusGreen(theme)),
                              onPressed: () => ref.read(activeSessionProvider.notifier).updatePartyHealth(member.id, member.type, _delta),
                              iconSize: 28,
                            ),
                            IconButton(
                              icon: AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.expand_more),
                              ),
                              onPressed: () => setState(() => _isExpanded = !_isExpanded),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'DEAD',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // ── Stats row (always visible, below header on narrow screens) ──
                      if (!member.isDead) ...[
                        if (!wideEnough) ...[
                          const SizedBox(height: 12),
                          _StatTable(stats: stats),
                        ],
                      ],

                      // ── Round Status (only when expanded) ──
                      if (_isExpanded && !member.isDead) ...[
                        const SizedBox(height: 12),
                        Text('Round Status', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  member.hasActed ? Icons.check_circle : Icons.check_circle_outline,
                                  color: member.hasActed ? statusGreen(theme) : theme.colorScheme.onSurfaceVariant,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    member.hasActed ? 'Activated this turn' : 'Not yet activated',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: member.hasActed
                                      ? null
                                      : () => ref.read(activeSessionProvider.notifier)
                                          .markPartyActed(member.id, member.type),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.secondary,
                                  ),
                                  child: Text(member.hasActed ? 'Done' : 'Activate'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.diamond,
                                  color: member.carryingTreasure
                                      ? Colors.amber
                                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    member.carryingTreasure ? 'Carrying a treasure' : 'Not carrying treasure',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => ref.read(activeSessionProvider.notifier)
                                      .toggleCarryingTreasure(member.id, member.type),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.secondary,
                                  ),
                                  child: Text(member.carryingTreasure ? 'Remove' : 'Carry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ── Status Effects (only when expanded) ──
                      if (_isExpanded && !member.isDead) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Status Effects', style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            )),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Manage'),
                              onPressed: () => _showStatusEffectSheet(context, member),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildStatusEffectsSection(context, member, ranger),
                      ],

                      // ── Heroic Abilities (only when expanded) ──
                      if (_isExpanded && !member.isDead && memberHeroicAbilities.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Heroic Abilities', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        ...memberHeroicAbilities.map((ability) {
                          final isUsed = member.usedAbilities[ability.key] ?? false;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.push('/reference/heroic_abilities/${ability.key}'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            ability.name,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            ability.description,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: isUsed,
                                      onChanged: (_) => ref.read(activeSessionProvider.notifier).toggleAbilityUsed(member.id, member.type, ability.key),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],

                      // ── Spells (only when expanded) ──
                      if (_isExpanded && !member.isDead && memberSpells.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Spells', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        ...memberSpells.map((spell) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.push('/reference/spells/${spell.key}'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.tertiary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            spell.name,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            spell.description,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],

                      // ── Skills (only when expanded) ──
                      if (_isExpanded && !member.isDead && memberSkills.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Skills', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: memberSkills.map((skill) {
                            return ActionChip(
                              label: Text('${skill.name} +${skill.value}'),
                              onPressed: () => context.push('/reference/skills/${skill.key}'),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            );
                          }).toList(),
                        ),
                      ],

                      // ── Equipment rows (only when expanded) ──
                      if (_isExpanded && !member.isDead && memberEquip.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Equipment', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        ...memberEquip.map((item) {
                          final hasUses = item.equipment.currentUses != null && item.equipment.currentUses! > 0;
                          final effects = Map<String, dynamic>.from(
                            const JsonDecoder().convert(item.effects) as Map,
                          );
                          final damageMod = effects['damage_modifier'] as int?;
                          final armourMod = effects['armour_bonus'] as int?;
                          final label = StringBuffer(item.name);
                          if (damageMod != null) label.write(' ${damageMod >= 0 ? '+' : ''}$damageMod');
                          if (armourMod != null) label.write(' ${armourMod >= 0 ? '+' : ''}$armourMod');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          label.toString(),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (hasUses)
                                          Text(
                                            'Uses: ${item.equipment.currentUses}',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (hasUses)
                                    TextButton.icon(
                                      icon: const Icon(Icons.remove_circle_outline, size: 22, color: Colors.red),
                                      label: const Text('Use', style: TextStyle(fontSize: 15, color: Colors.red)),
                                      onPressed: () => _confirmAndUseItem(context, item.equipment, item.name),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Switch(
                                    value: item.isActive,
                                    onChanged: (_) => _toggleItemActive(item.equipment),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusEffectsSection(BuildContext context, PartyMemberState member, RangerDetail ranger) {
    final displayInjuries = member.type == 'ranger'
        ? ((ranger.ranger.notes.contains('[Injury]'))
            ? RegExp(r'\[Injury\]\s*(\w+(?:_\w+)*)')
                .allMatches(ranger.ranger.notes)
                .map((m) => m.group(1)!)
                .toList()
            : <String>[])
        : (ranger.companions.where((c) => c.id == member.id).firstOrNull != null
            ? List<String>.from(
                jsonDecode(ranger.companions
                    .firstWhere((c) => c.id == member.id).permanentInjuries) as List? ?? [],
              )
            : <String>[]);

    if (member.statusEffects.isEmpty && displayInjuries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('No status effects', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        ...member.statusEffects.map((key) => _buildEffectChip(context, key, isInjury: false)),
        ...displayInjuries.map((key) => _buildEffectChip(context, key, isInjury: true)),
      ],
    );
  }

  Widget _buildEffectChip(BuildContext context, String key, {required bool isInjury}) {
    final theme = Theme.of(context);
    final effect = getStatusEffect(key);
    final injury = permanentInjuries.where((i) => i.key == key).firstOrNull;
    final name = effect?.name ?? injury?.name ?? key.replaceAll('_', ' ');

    Color chipColor;
    if (isInjury) {
      chipColor = theme.colorScheme.error;
    } else if (effect?.category == StatusEffectCategory.positive) {
      chipColor = Colors.green;
    } else {
      chipColor = theme.colorScheme.error;
    }

    return InputChip(
      label: Text(name, style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      deleteIcon: Icon(Icons.close, size: 14, color: Colors.white70),
      onDeleted: () => ref.read(activeSessionProvider.notifier)
          .removeStatusEffectFromMember(widget.member.id, widget.member.type, key),
      onPressed: () => context.push(
        isInjury
            ? '/reference/permanent_injuries/$key'
            : '/reference/status_effects/$key',
      ),
    );
  }

  Future<void> _showStatusEffectSheet(BuildContext context, PartyMemberState member) async {
    final currentEffects = List<String>.from(member.statusEffects);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      builder: (ctx) => _StatusEffectSheet(activeEffects: currentEffects),
    );
    if (result != null) {
      ref.read(activeSessionProvider.notifier)
          .updateMemberStatusEffects(widget.member.id, widget.member.type, result.toList());
    }
  }
}

class _StatusEffectSheet extends StatefulWidget {
  final List<String> activeEffects;

  const _StatusEffectSheet({required this.activeEffects});

  @override
  State<_StatusEffectSheet> createState() => _StatusEffectSheetState();
}

class _StatusEffectSheetState extends State<_StatusEffectSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.activeEffects);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Status Effects',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...statusEffects.map((effect) => CheckboxListTile(
              title: Text(effect.name),
              subtitle: Text(effect.description, style: theme.textTheme.bodySmall),
              value: _selected.contains(effect.key),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selected.add(effect.key);
                  } else {
                    _selected.remove(effect.key);
                  }
                });
              },
              secondary: Icon(
                effect.category == StatusEffectCategory.positive
                    ? Icons.arrow_upward : Icons.arrow_downward,
                color: effect.category == StatusEffectCategory.positive
                    ? Colors.green : theme.colorScheme.error,
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _selected),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTable extends StatelessWidget {
  const _StatTable({required this.stats});

  final StatRow stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const cellWidth = 30.0;
    final labels = <String>['M', 'F', 'S', 'A', 'W', 'H'];
    final values = <int>[stats.move, stats.fight, stats.shoot, stats.armour, stats.will, stats.health];
    if (stats.damage != null) {
      labels.add('D');
      values.add(stats.damage!);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: labels.map((l) => SizedBox(
            width: cellWidth,
            child: Text(l, textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              )),
          )).toList(),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < values.length; i++)
              SizedBox(
                width: cellWidth,
                child: Text('${values[i]}', textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stats.damage != null && i >= 6
                        ? theme.colorScheme.tertiary
                        : null,
                  )),
              ),
          ],
        ),
      ],
    );
  }
}

Map<String, int> _computeEquipMods(List<RangerEquipmentWithName> items) {
  final stats = <String, int>{};
  const effectMappings = {
    'armour_bonus': 'armour',
    'fight_bonus': 'fight',
    'fight_penalty': 'fight',
    'shoot_bonus': 'shoot',
    'will_bonus': 'will',
    'will_penalty': 'will',
    'move_bonus': 'move',
    'move_penalty': 'move',
    'damage_modifier': 'damage',
  };
  for (final item in items) {
    if (!item.isActive) continue;
    try {
      final effects = item.effects;
      if (effects.isEmpty) continue;
      final parsed = Map<String, dynamic>.from(
        const JsonDecoder().convert(effects) as Map,
      );
      for (final entry in effectMappings.entries) {
        final mod = parsed[entry.key] as int?;
        if (mod != null) {
          stats.update(entry.value, (v) => v + mod, ifAbsent: () => mod);
        }
      }
    } catch (_) {}
  }
  return stats;
}

class StatRow {
  final int move;
  final int fight;
  final int shoot;
  final int armour;
  final int will;
  final int health;
  final int? damage;

  const StatRow({
    required this.move,
    required this.fight,
    required this.shoot,
    required this.armour,
    required this.will,
    required this.health,
    this.damage,
  });
}

class _NamedAbility {
  final String key;
  final String name;
  final String description;
  const _NamedAbility({required this.key, required this.name, required this.description});
}

class _NamedSkill {
  final String key;
  final String name;
  final int value;
  const _NamedSkill({required this.key, required this.name, required this.value});
}

// Creature Panel
class _CreaturePanel extends StatelessWidget {
  const _CreaturePanel({required this.session});

  final ActiveSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Creatures',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${session.creatures.where((c) => !c.isDead).length} alive',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (session.creatures.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No creatures added yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...session.creatures.map((creature) => _CreatureCard(creature: creature)),
      ],
    );
  }
}

class _CreatureCard extends ConsumerStatefulWidget {
  const _CreatureCard({required this.creature});

  final CreatureData creature;

  @override
  ConsumerState<_CreatureCard> createState() => _CreatureCardState();
}

class _CreatureCardState extends ConsumerState<_CreatureCard> {
  final TextEditingController _deltaController = TextEditingController(text: '1');

  @override
  void dispose() {
    _deltaController.dispose();
    super.dispose();
  }

  int get _delta => int.tryParse(_deltaController.text) ?? 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final creature = widget.creature;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: creature.isDead ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              backgroundColor: creature.isDead
                  ? theme.colorScheme.error
                  : theme.colorScheme.errorContainer,
              child: Icon(
                creature.isDead ? Icons.close : Icons.pets,
                color: creature.isDead
                    ? theme.colorScheme.onError
                    : theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: 12),

            // Name and HP bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creature.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: creature.isDead ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // HP bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: creature.maxHealth > 0 ? creature.currentHealth / creature.maxHealth : 0,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: creature.currentHealth <= 0
                          ? theme.colorScheme.error
                          : creature.currentHealth <= creature.maxHealth ~/ 3
                              ? statusOrange(theme)
                              : theme.colorScheme.error,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HP: ${creature.currentHealth}/${creature.maxHealth}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // HP Controls
            if (!creature.isDead) ...[
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
                onPressed: () => ref.read(activeSessionProvider.notifier).updateCreatureHealth(creature.id, -_delta),
                iconSize: 28,
              ),
              SizedBox(
                width: 44,
                child: TextField(
                  controller: _deltaController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: statusGreen(theme)),
                onPressed: () => ref.read(activeSessionProvider.notifier).updateCreatureHealth(creature.id, _delta),
                iconSize: 28,
              ),
            ],
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () => ref.read(activeSessionProvider.notifier).removeCreature(creature.id),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}

// Event Log
class _EventLog extends StatelessWidget {
  const _EventLog({required this.session});

  final ActiveSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Log',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (session.eventLog.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No events yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...session.eventLog.reversed.take(20).map((event) => _EventTile(event: event)),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final EventLogEntry event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (event.eventType) {
      case 'damage':
        icon = Icons.local_fire_department;
        color = theme.colorScheme.error;
        break;
      case 'heal':
        icon = Icons.favorite;
        color = statusGreen(theme);
        break;
      case 'ability_used':
        icon = Icons.auto_awesome;
        color = statusPurple(theme);
        break;
      case 'spell_cast':
        icon = Icons.cast;
        color = statusBlue(theme);
        break;
      case 'skill_roll':
        icon = Icons.casino;
        color = statusOrange(theme);
        break;
      case 'death':
        icon = Icons.dangerous;
        color = theme.colorScheme.error;
        break;
      default:
        icon = Icons.note;
        color = theme.colorScheme.onSurfaceVariant;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          event.description,
          style: theme.textTheme.bodySmall,
        ),
        subtitle: Text(
          'Turn ${event.turnNumber} • ${event.phase.name}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// Dice Roller Bottom Sheet
class _DiceRollerSheet extends StatefulWidget {
  const _DiceRollerSheet();

  @override
  State<_DiceRollerSheet> createState() => _DiceRollerSheetState();
}

class _DiceRollerSheetState extends State<_DiceRollerSheet> {
  final _modifierController = TextEditingController(text: '0');
  int? _lastRoll;
  final List<String> _history = [];

  @override
  void dispose() {
    _modifierController.dispose();
    super.dispose();
  }

  void _rollDice() {
    final modifier = int.tryParse(_modifierController.text) ?? 0;
    final roll = (DateTime.now().microsecondsSinceEpoch % 20) + 1;
    final total = roll + modifier;

    setState(() {
      _lastRoll = total;
      _history.insert(0, 'd20: $roll${modifier != 0 ? (modifier > 0 ? ' + $modifier' : ' - ${modifier.abs()}') : ''} = $total');
      if (_history.length > 10) _history.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Dice Roller',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Roll result
          if (_lastRoll != null)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: Center(
                child: Text(
                  '$_lastRoll',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                Icons.casino,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 16),

          // Modifier input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _modifierController,
                  decoration: const InputDecoration(
                    labelText: 'Modifier',
                    prefixIcon: Icon(Icons.calculate),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Roll button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _rollDice,
              icon: const Icon(Icons.casino),
              label: const Text('Roll d20'),
            ),
          ),
          const SizedBox(height: 16),

          // History
          if (_history.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _history[index],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
