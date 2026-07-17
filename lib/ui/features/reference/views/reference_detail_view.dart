import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/reference_provider.dart';
import '../../../../data/services/rules_reference_service.dart';
import '../../../core/widgets/stat_display.dart';

class ReferenceDetailView extends ConsumerWidget {
  const ReferenceDetailView({
    super.key,
    required this.categoryKey,
    required this.entryId,
  });

  final String categoryKey;
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(
      referenceEntryProvider((category: categoryKey, id: entryId)),
    );

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Entry not found')),
      );
    }

    final isFav = ref.watch(referenceFavoriteIdsProvider).contains(entry.id);
    final category = referenceCategories.where((c) => c.key == categoryKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(referenceFavoriteIdsProvider.notifier)
                  .toggle(entry.id);
            },
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (category.isNotEmpty) ...[
            _CategoryLabel(
              icon: category.first.icon,
              label: category.first.label,
            ),
            const SizedBox(height: 16),
          ],

          // Title
          Text(
            entry.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Category-specific content
          ..._buildCategoryContent(context, entry),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryContent(BuildContext context, ReferenceEntry entry) {
    final theme = Theme.of(context);

    switch (entry.category) {
      case 'heroic_abilities':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          if (entry.metadata.containsKey('when_to_use'))
            _InfoBlock(
              label: 'When to Use',
              content: entry.metadata['when_to_use']!,
              color: theme.colorScheme.tertiaryContainer,
            ),
        ];

      case 'spells':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          _InfoBlock(
            label: 'Target',
            content: entry.metadata['target_type']?.replaceAll('_', ' ') ?? 'N/A',
            color: theme.colorScheme.tertiaryContainer,
          ),
          if (entry.metadata.containsKey('will_roll_tn'))
            _InfoBlock(
              label: 'Will Roll to Resist',
              content: 'TN ${entry.metadata['will_roll_tn']}',
              color: theme.colorScheme.errorContainer,
            ),
        ];

      case 'skills':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
        ];

      case 'companions':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          const SizedBox(height: 16),
          Text(
            'Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StatTable(
            labels: const ['M', 'F', 'S', 'A', 'W', 'H'],
            values: [
              int.tryParse(entry.metadata['move'] ?? '') ?? 0,
              int.tryParse(entry.metadata['fight'] ?? '') ?? 0,
              int.tryParse(entry.metadata['shoot'] ?? '') ?? 0,
              int.tryParse(entry.metadata['armour'] ?? '') ?? 0,
              int.tryParse(entry.metadata['will'] ?? '') ?? 0,
              int.tryParse(entry.metadata['health'] ?? '') ?? 0,
            ],
          ),
          const SizedBox(height: 16),
          if (entry.metadata.containsKey('rp_cost'))
            _InfoBlock(
              label: 'Recruitment Points',
              content: entry.metadata['rp_cost']!,
              color: theme.colorScheme.secondaryContainer,
            ),
          if (entry.metadata.containsKey('notes'))
            _InfoBlock(label: 'Equipment', content: entry.metadata['notes']!),
          if (entry.metadata['is_animal'] == 'true')
            _InfoBlock(
              label: 'Animal',
              content: 'Cannot carry treasure or items. Limited skill rolls.',
              color: theme.colorScheme.tertiaryContainer,
            ),
          if (entry.metadata.containsKey('base_skills') &&
              entry.metadata['base_skills']!.isNotEmpty)
            _InfoBlock(
              label: 'Base Skills',
              content: entry.metadata['base_skills']!,
              color: theme.colorScheme.secondaryContainer,
            ),
          if (entry.detailedDescription != null)
            _InfoBlock(
              label: 'Special Rules',
              content: entry.detailedDescription!,
              color: theme.colorScheme.tertiaryContainer,
            ),
        ];

      case 'basic_equipment':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          _InfoBlock(
            label: 'Type',
            content: entry.metadata['category_type']?.replaceAll('_', ' ') ?? '',
            color: theme.colorScheme.tertiaryContainer,
          ),
          if (entry.metadata['two_handed'] == 'true')
            _InfoBlock(
              label: 'Two-Handed',
              content: 'Cannot be used with a shield.',
              color: theme.colorScheme.tertiaryContainer,
            ),
          if (entry.metadata['light'] == 'true')
            _InfoBlock(
              label: 'Light Armour',
              content: 'Made of non-metal materials.',
              color: theme.colorScheme.tertiaryContainer,
            ),
        ];

      case 'magic_items':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          if (entry.metadata.containsKey('max_uses'))
            _InfoBlock(
              label: 'Uses',
              content: entry.metadata['max_uses']!,
              color: theme.colorScheme.secondaryContainer,
            ),
          _InfoBlock(
            label: 'Type',
            content: entry.metadata['category_type']?.replaceAll('_', ' ') ?? '',
            color: theme.colorScheme.tertiaryContainer,
          ),
        ];

      case 'herbs_potions':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          _InfoBlock(
            label: 'Type',
            content: 'Herb / Potion',
            color: theme.colorScheme.tertiaryContainer,
          ),
        ];

      case 'permanent_injuries':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          _InfoBlock(
            label: 'Effect',
            content: entry.metadata['effect'] ?? '',
            color: theme.colorScheme.errorContainer,
          ),
          _InfoBlock(
            label: 'Cumulative',
            content: entry.metadata.containsKey('affected_stat')
                ? 'Affects ${entry.metadata['affected_stat']!.replaceAll('_', ' ')}. '
                    'Max ${entry.metadata['max_times']} times.'
                : 'Max ${entry.metadata['max_times']} time(s).',
            color: theme.colorScheme.tertiaryContainer,
          ),
        ];

      case 'treasure_tables':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          if (entry.metadata.containsKey('table_data'))
            _TableBlock(content: entry.metadata['table_data']!),
        ];

      default:
        return [
          _InfoBlock(label: 'Description', content: entry.description),
        ];
    }
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.content,
    this.color,
  });

  final String label;
  final String content;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = color ?? theme.colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableBlock extends StatelessWidget {
  const _TableBlock({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = content.split('\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
