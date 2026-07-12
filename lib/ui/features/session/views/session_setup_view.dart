import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/ranger_repository_provider.dart';
import '../../../../data/repositories/companion_repository_provider.dart';
import '../../rangers/view_models/rangers_provider.dart';
import '../view_models/session_provider.dart';

class SessionSetupView extends ConsumerStatefulWidget {
  const SessionSetupView({super.key});

  @override
  ConsumerState<SessionSetupView> createState() => _SessionSetupViewState();
}

class _SessionSetupViewState extends ConsumerState<SessionSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _scenarioController = TextEditingController();
  final _missionController = TextEditingController();
  int? _selectedRangerId;
  bool _isStarting = false;

  @override
  void dispose() {
    _scenarioController.dispose();
    _missionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rangersAsync = ref.watch(rangersListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start New Session'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ranger Selection
            Text(
              'Select Ranger',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            rangersAsync.when(
              data: (rangers) {
                if (rangers.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.person_off, size: 48, color: theme.colorScheme.error),
                          const SizedBox(height: 8),
                          Text(
                            'No rangers created yet',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            onPressed: () => context.push('/rangers/create'),
                            child: const Text('Create a Ranger'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return DropdownButtonFormField<int>(
                  value: _selectedRangerId,
                  decoration: const InputDecoration(
                    labelText: 'Ranger',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: rangers.map((ranger) {
                    return DropdownMenuItem(
                      value: ranger.id,
                      child: Text('${ranger.name} (Lv ${ranger.level})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRangerId = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Please select a ranger';
                    return null;
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
            const SizedBox(height: 24),

            // Scenario Name
            Text(
              'Scenario Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _scenarioController,
              decoration: const InputDecoration(
                labelText: 'Scenario Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map),
                hintText: 'e.g., The Siege of Northwatch',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a scenario name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _missionController,
              decoration: const InputDecoration(
                labelText: 'Mission (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
                hintText: 'e.g., Mission 3: The Rescue',
              ),
            ),
            const SizedBox(height: 24),

            // Party Preview
            if (_selectedRangerId != null) ...[
              Text(
                'Your Party',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _PartyPreview(rangerId: _selectedRangerId!),
            ],
            const SizedBox(height: 24),

            // Start Button
            FilledButton.icon(
              onPressed: _isStarting ? null : _startSession,
              icon: _isStarting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isStarting ? 'Starting...' : 'Start Session'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSession() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRangerId == null) return;

    setState(() => _isStarting = true);

    try {
      final sessionNotifier = ref.read(activeSessionProvider.notifier);
      final rangerRepo = ref.read(rangerRepositoryProvider);
      final companionRepo = ref.read(companionRepositoryProvider);

      // Get ranger and companions for party
      final ranger = await rangerRepo.getRangerById(_selectedRangerId!);
      if (ranger == null) return;

      final companionRows = await companionRepo.getCompanionsByRanger(_selectedRangerId!);

      // Build party
      final party = <PartyMemberState>[
        PartyMemberState(
          id: ranger.id,
          name: ranger.name,
          type: 'ranger',
          currentHealth: ranger.currentHealth,
          maxHealth: ranger.health,
        ),
      ];

      for (final comp in companionRows) {
        party.add(PartyMemberState(
          id: comp.id,
          name: comp.customName,
          type: 'companion',
          currentHealth: 1 + comp.bonusHealth,
          maxHealth: 1 + comp.bonusHealth,
        ));
      }

      // Start session
      await sessionNotifier.startSession(
        rangerId: _selectedRangerId!,
        scenarioName: _scenarioController.text.trim(),
        missionName: _missionController.text.trim(),
        initialParty: party,
      );

      if (mounted) {
        // Navigate to active session
        final sessionId = ref.read(activeSessionProvider).sessionId;
        context.go('/session/active/$sessionId');
      }
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }
}

// Party preview widget
class _PartyPreview extends ConsumerWidget {
  const _PartyPreview({required this.rangerId});

  final int rangerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangersAsync = ref.watch(rangersListProvider);
    final theme = Theme.of(context);

    return rangersAsync.when(
      data: (rangers) {
        final ranger = rangers.where((r) => r.id == rangerId).firstOrNull;
        if (ranger == null) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ranger
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ranger.name,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Ranger • HP: ${ranger.currentHealth}/${ranger.health}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Stats preview
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _StatChip(label: 'M', value: ranger.move),
                    _StatChip(label: 'F', value: ranger.fight),
                    _StatChip(label: 'S', value: ranger.shoot),
                    _StatChip(label: 'A', value: ranger.armour),
                    _StatChip(label: 'W', value: ranger.will),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
