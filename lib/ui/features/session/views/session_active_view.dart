import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/creatures.dart' show creatures, searchCreatures, CreatureDefinition;
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';
import 'package:rangers_mobile/ui/features/session/widgets/creature_card.dart';
import 'package:rangers_mobile/ui/features/session/widgets/dice_roller_sheet.dart';
import 'package:rangers_mobile/ui/features/session/widgets/party_member_card.dart';
import 'package:rangers_mobile/ui/features/session/widgets/session_models.dart';
import 'package:rangers_mobile/ui/features/session/widgets/session_widgets.dart';

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
          IconButton(
            icon: const Icon(Icons.casino),
            onPressed: () => _showDiceRoller(context),
            tooltip: 'Roll Dice',
          ),
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
          TurnTracker(session: session),

          PhaseIndicator(
            currentPhase: session.currentPhase,
            onNextPhase: () => ref.read(activeSessionProvider.notifier).nextPhase(),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PartyPanel(session: session),
                const SizedBox(height: 16),

                CreaturePanel(
                  session: session,
                  onAddCreature: () => _showAddCreatureDialog(context, ref),
                ),
                const SizedBox(height: 16),

                EventLog(session: session),
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
      builder: (context) => const DiceRollerSheet(),
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
    bool showCustom = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Creature'),
          content: SizedBox(
            width: double.maxFinite,
            child: showCustom
                ? Column(
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => setDialogState(() => showCustom = false),
                            child: const Text('Back to Bestiary'),
                          ),
                        ],
                      ),
                    ],
                  )
                : _CreaturePicker(
                    onSelect: (creature) {
                      ref.read(activeSessionProvider.notifier).addCreatureFromBestiary(creature.key);
                      Navigator.pop(context);
                    },
                    onCreateCustom: () => setDialogState(() => showCustom = true),
                  ),
          ),
          actions: showCustom
              ? [
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
                ]
              : null,
        ),
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

// ── Searchable creature picker widget ──

class _CreaturePicker extends StatefulWidget {
  const _CreaturePicker({
    required this.onSelect,
    required this.onCreateCustom,
  });

  final void Function(CreatureDefinition creature) onSelect;
  final VoidCallback onCreateCustom;

  @override
  State<_CreaturePicker> createState() => _CreaturePickerState();
}

class _CreaturePickerState extends State<_CreaturePicker> {
  final _searchController = TextEditingController();
  List<CreatureDefinition> _filtered = creatures;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = searchCreatures(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search creatures...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _onSearch,
          autofocus: true,
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              ..._filtered.map((creature) => _CreatureTile(
                    creature: creature,
                    onTap: () => widget.onSelect(creature),
                  )),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.add, size: 18, color: theme.colorScheme.onSecondaryContainer),
                ),
                title: Text(
                  'Custom Creature',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Enter name and HP manually',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: widget.onCreateCustom,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreatureTile extends StatelessWidget {
  const _CreatureTile({required this.creature, required this.onTap});

  final CreatureDefinition creature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Text(
                      '${creature.move}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      creature.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'XP ${creature.xpValue}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StatTable(
                stats: StatRow(
                  move: creature.move,
                  fight: creature.fight,
                  shoot: creature.shoot,
                  armour: creature.armour,
                  will: creature.will,
                  health: creature.health,
                ),
              ),
              if (creature.notes.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  creature.notes,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
