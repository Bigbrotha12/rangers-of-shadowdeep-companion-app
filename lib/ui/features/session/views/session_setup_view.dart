import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/data/database/app_database.dart' show RangerCompanion;
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart' show companionTypeKeyFromId, getCompanionType;
import 'package:rangers_mobile/domain/services/stat_calculation_service.dart' show computeStatPenalty;
import 'package:rangers_mobile/ui/core/widgets/stat_display.dart' show StatTable;
import 'package:rangers_mobile/ui/features/rangers/view_models/rangers_provider.dart';
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';

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
                  initialValue: _selectedRangerId,
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

      final companionRows = await companionRepo.getCompanionsByRanger(_selectedRangerId!, isActive: true);

      // Build party
      final rangerEffects = List<String>.from(
        jsonDecode(ranger.statusEffects) as List? ?? [],
      );
      final party = <PartyMemberState>[
        PartyMemberState(
          id: ranger.id,
          name: ranger.name,
          type: 'ranger',
          currentHealth: ranger.currentHealth,
          maxHealth: ranger.health,
          statusEffects: rangerEffects,
        ),
      ];

      for (final comp in companionRows) {
        final compEffects = List<String>.from(
          jsonDecode(comp.statusEffects) as List? ?? [],
        );
        final compInjuries = List<String>.from(
          jsonDecode(comp.permanentInjuries) as List? ?? [],
        );
        final compTypeKey = companionTypeKeyFromId(comp.companionTypeId);
        final compType = getCompanionType(compTypeKey);
        final baseHealth = compType?.health ?? 10;
        final injuryPenalty = computeStatPenalty('health',
          permanentInjuryKeys: compInjuries,
          statusEffectKeys: compEffects,
        );
        final effectiveHP = baseHealth + injuryPenalty + comp.bonusHealth;
        party.add(PartyMemberState(
          id: comp.id,
          name: comp.customName,
          type: 'companion',
          isAnimal: compType?.isAnimal ?? false,
          currentHealth: effectiveHP,
          maxHealth: effectiveHP,
          statusEffects: compEffects,
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
    final companionRepo = ref.watch(companionRepositoryProvider);
    final theme = Theme.of(context);

    return rangersAsync.when(
      data: (rangers) {
        final ranger = rangers.where((r) => r.id == rangerId).firstOrNull;
        if (ranger == null) return const SizedBox.shrink();

        return FutureBuilder<List<RangerCompanion>>(
          future: companionRepo.getCompanionsByRanger(rangerId, isActive: true),
          builder: (context, snapshot) {
            final companions = snapshot.data ?? <RangerCompanion>[];

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
                        const SizedBox(width: 8),
                        StatTable(
                          labels: const ['M', 'F', 'S', 'A', 'W', 'H'],
                          values: [
                            ranger.move,
                            ranger.fight,
                            ranger.shoot,
                            ranger.armour,
                            ranger.will,
                            ranger.health,
                          ],
                          highlightLast: true,
                        ),
                      ],
                    ),
                    // Companions
                    if (companions.isNotEmpty) ...[
                      const Divider(height: 24),
                      Text(
                        'Companions (${companions.length})',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...companions.map((comp) {
                        final typeKey = companionTypeKeyFromId(comp.companionTypeId);
                        final type = getCompanionType(typeKey);
                        final previewInjuries = List<String>.from(
                          jsonDecode(comp.permanentInjuries) as List? ?? [],
                        );
                        final previewEffects = List<String>.from(
                          jsonDecode(comp.statusEffects) as List? ?? [],
                        );
                        final compBaseHealth = type?.health ?? 10;
                        final healthPenalty = computeStatPenalty('health',
                          permanentInjuryKeys: previewInjuries,
                          statusEffectKeys: previewEffects,
                        );
                        final effectiveHP = compBaseHealth + healthPenalty + comp.bonusHealth;
                        final compMove = (type?.move ?? 6) + computeStatPenalty('move',
                          permanentInjuryKeys: previewInjuries,
                          statusEffectKeys: previewEffects,
                        );
                        final compFight = (type?.fight ?? 0) + computeStatPenalty('fight',
                          permanentInjuryKeys: previewInjuries,
                          statusEffectKeys: previewEffects,
                        );
                        final compShoot = (type?.shoot ?? 0) + computeStatPenalty('shoot',
                          permanentInjuryKeys: previewInjuries,
                          statusEffectKeys: previewEffects,
                        );
                        final compArmour = type?.armour ?? 10;
                        final compWill = (type?.will ?? 0) + computeStatPenalty('will',
                          permanentInjuryKeys: previewInjuries,
                          statusEffectKeys: previewEffects,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.secondaryContainer,
                                child: Icon(Icons.pets, color: theme.colorScheme.onSecondaryContainer, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comp.customName,
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${type?.name ?? 'Companion'} • '
                                      'HP: $effectiveHP/$effectiveHP '
                                      '• PP: ${comp.progressionPoints}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatTable(
                                labels: const ['M', 'F', 'S', 'A', 'W', 'H'],
                                values: [
                                  compMove,
                                  compFight,
                                  compShoot,
                                  compArmour,
                                  compWill,
                                  effectiveHP,
                                ],
                                highlightLast: true,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

