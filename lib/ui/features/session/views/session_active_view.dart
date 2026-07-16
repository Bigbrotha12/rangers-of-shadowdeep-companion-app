import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/session_provider.dart';

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
          // End session
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'end') _showEndSessionDialog(context, ref);
              if (value == 'add_creature') _showAddCreatureDialog(context, ref);
              if (value == 'add_note') _showAddNoteDialog(context, ref);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'add_creature', child: Text('Add Creature')),
              const PopupMenuItem(value: 'add_note', child: Text('Add Note')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'end',
                child: Text('End Session', style: TextStyle(color: Colors.red)),
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
          ...session.party.map((member) => _PartyMemberCard(member: member)),
      ],
    );
  }
}

class _PartyMemberCard extends ConsumerStatefulWidget {
  const _PartyMemberCard({required this.member});

  final PartyMemberState member;

  @override
  ConsumerState<_PartyMemberCard> createState() => _PartyMemberCardState();
}

class _PartyMemberCardState extends ConsumerState<_PartyMemberCard> {
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
    final member = widget.member;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: member.isDead ? theme.colorScheme.errorContainer.withValues(alpha: 0.3) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
                              ? Colors.orange
                              : null,
                    ),
                  ),
                ],
              ),
            ),

            // HP Controls
            if (!member.isDead) ...[
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => ref.read(activeSessionProvider.notifier).updatePartyHealth(member.id, -_delta),
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
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () => ref.read(activeSessionProvider.notifier).updatePartyHealth(member.id, _delta),
                iconSize: 28,
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
      ),
    );
  }
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
                              ? Colors.orange
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
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
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
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
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
        color = Colors.red;
        break;
      case 'heal':
        icon = Icons.favorite;
        color = Colors.green;
        break;
      case 'ability_used':
        icon = Icons.auto_awesome;
        color = Colors.purple;
        break;
      case 'spell_cast':
        icon = Icons.cast;
        color = Colors.blue;
        break;
      case 'skill_roll':
        icon = Icons.casino;
        color = Colors.orange;
        break;
      case 'death':
        icon = Icons.dangerous;
        color = Colors.red;
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
