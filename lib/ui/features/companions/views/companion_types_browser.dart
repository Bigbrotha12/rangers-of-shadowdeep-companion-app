import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/basic_equipment.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/ui/core/widgets/stat_display.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_types_provider.dart';

class CompanionTypesBrowser extends ConsumerWidget {
  const CompanionTypesBrowser({required this.rangerId, super.key});

  final int rangerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companionTypes = ref.watch(companionTypesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Companion Types'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Human'),
              Tab(text: 'Animal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CompanionList(
              rangerId: rangerId,
              companions: companionTypes.where((c) => !c.isAnimal).toList(),
            ),
            _CompanionList(
              rangerId: rangerId,
              companions: companionTypes.where((c) => c.isAnimal).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionList extends StatelessWidget {
  const _CompanionList({required this.rangerId, required this.companions});

  final int rangerId;
  final List<CompanionTypeDefinition> companions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: companions.length,
      itemBuilder: (context, index) {
        final companion = companions[index];
        return _CompanionCard(rangerId: rangerId, companion: companion);
      },
    );
  }
}

class _CompanionCard extends StatelessWidget {
  const _CompanionCard({required this.rangerId, required this.companion});

  final int rangerId;
  final CompanionTypeDefinition companion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTypeDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      companion.isAnimal ? Icons.pets : Icons.person,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companion.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'RP: ${companion.rpCost}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StatTable(
                labels: const ['M', 'F', 'S', 'A', 'W', 'H'],
                values: [companion.move, companion.fight, companion.shoot, companion.armour, companion.will, companion.health],
              ),
              const SizedBox(height: 8),
              Text(
                companion.notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTypeDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _TypeDetailSheet(
          rangerId: rangerId,
          companion: companion,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _TypeDetailSheet extends StatelessWidget {
  const _TypeDetailSheet({
    required this.rangerId,
    required this.companion,
    required this.scrollController,
  });

  final int rangerId;
  final CompanionTypeDefinition companion;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  companion.isAnimal ? Icons.pets : Icons.person,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companion.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${companion.rpCost} Recruitment Points',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(companion.description),
          const SizedBox(height: 24),

          // Stats
          Text(
            'Base Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          StatTable(
            labels: const ['M', 'F', 'S', 'A', 'W', 'H'],
            values: [companion.move, companion.fight, companion.shoot, companion.armour, companion.will, companion.health],
          ),
          const SizedBox(height: 24),

          // Equipment
          Text(
            'Equipment',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _EquipmentContent(companion: companion),
          const SizedBox(height: 24),

          // Special Rules
          if (companion.specialRules != null) ...[
            Text(
              'Special Rules',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                companion.specialRules!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Base Skills
          if (companion.baseSkills.isNotEmpty) ...[
            Text(
              'Base Skills',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: companion.baseSkills.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key.replaceAll('_', ' ')} +${entry.value}'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Allowed Skill Rolls (animals)
          if (companion.allowedSkillRolls != null) ...[
            Text(
              'Allowed Skill Rolls',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: companion.allowedSkillRolls!.map((skill) {
                return Chip(
                  label: Text(skill.replaceAll('_', ' ')),
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Recruit button
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/rangers/$rangerId/companions/recruit');
            },
            icon: const Icon(Icons.add),
            label: const Text('Recruit This Companion'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EquipmentContent extends StatelessWidget {
  const _EquipmentContent({required this.companion});

  final CompanionTypeDefinition companion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final equipment = <String>[
      for (final key in companion.allowedWeaponTypes)
        getBasicEquipment(key)?.name ?? key.replaceAll('_', ' '),
      for (final key in companion.allowedArmourTypes)
        getBasicEquipment(key)?.name ?? key.replaceAll('_', ' '),
    ];

    if (equipment.isEmpty) {
      return Text(
        'No equipment',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: equipment.map((name) {
        return Chip(
          label: Text(name),
          backgroundColor: theme.colorScheme.primaryContainer,
        );
      }).toList(),
    );
  }
}
