import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/ui/features/reference/view_models/reference_provider.dart';
import 'package:rangers_mobile/data/services/rules_reference_service.dart';
import 'package:rangers_mobile/domain/constants/basic_equipment.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/ui/core/widgets/stat_display.dart';

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
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
        ];

      case 'spells':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          _InfoBlock(
            label: 'Target',
            content: entry.metadata['target_type']?.replaceAll('_', ' ') ?? 'N/A',
            color: theme.colorScheme.primaryContainer,
            textColor: theme.colorScheme.onPrimaryContainer,
          ),
          if (entry.metadata.containsKey('will_roll_tn'))
            _InfoBlock(
              label: 'Will Roll to Resist',
              content: 'TN ${entry.metadata['will_roll_tn']}',
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
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
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
          _EquipmentBlock(entry: entry),
          if (entry.metadata['is_animal'] == 'true')
            _InfoBlock(
              label: 'Animal',
              content: 'Cannot carry treasure or items. Limited skill rolls.',
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
          if (entry.metadata.containsKey('base_skills') &&
              entry.metadata['base_skills']!.isNotEmpty)
            _InfoBlock(
              label: 'Base Skills',
              content: entry.metadata['base_skills']!,
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
          if (entry.detailedDescription != null)
            _InfoBlock(
              label: 'Special Rules',
              content: entry.detailedDescription!,
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
        ];

      case 'basic_equipment':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          _InfoBlock(
            label: 'Type',
            content: entry.metadata['category_type']?.replaceAll('_', ' ') ?? '',
            color: theme.colorScheme.primaryContainer,
            textColor: theme.colorScheme.onPrimaryContainer,
          ),
          if (entry.metadata['two_handed'] == 'true')
            _InfoBlock(
              label: 'Two-Handed',
              content: 'Cannot be used with a shield.',
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
          if (entry.metadata['light'] == 'true')
            _InfoBlock(
              label: 'Light Armour',
              content: 'Made of non-metal materials.',
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
        ];

      case 'magic_items':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          if (entry.metadata.containsKey('max_uses'))
            _InfoBlock(
              label: 'Uses',
              content: entry.metadata['max_uses']!,
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
          _InfoBlock(
            label: 'Type',
            content: entry.metadata['category_type']?.replaceAll('_', ' ') ?? '',
            color: theme.colorScheme.primaryContainer,
            textColor: theme.colorScheme.onPrimaryContainer,
          ),
        ];

      case 'herbs_potions':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          _InfoBlock(
            label: 'Type',
            content: 'Herb / Potion',
            color: theme.colorScheme.primaryContainer,
            textColor: theme.colorScheme.onPrimaryContainer,
          ),
        ];

      case 'permanent_injuries':
        return [
          _InfoBlock(
            label: 'Description', 
            content: entry.description
            ),
          _InfoBlock(
            label: 'Effect',
            content: entry.metadata['effect'] ?? '',
            color: theme.colorScheme.primaryContainer,
            textColor: theme.colorScheme.onPrimaryContainer,
          ),
          _InfoBlock(
            label: 'Cumulative',
            content: entry.metadata.containsKey('affected_stat')
                ? 'Affects ${entry.metadata['affected_stat']!.replaceAll('_', ' ')}. '
                    'Max ${entry.metadata['max_times']} times.'
                : 'Max ${entry.metadata['max_times']} time(s).',
            color: theme.colorScheme.primaryContainer,
            textColor: theme.colorScheme.onPrimaryContainer,
          ),
        ];

      case 'creatures':
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
          if (entry.metadata.containsKey('xp_value'))
            _InfoBlock(
              label: 'Experience Points',
              content: entry.metadata['xp_value']!,
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
          if (entry.metadata.containsKey('notes') && entry.metadata['notes']!.isNotEmpty)
            _InfoBlock(
              label: 'Notes', 
              content: entry.metadata['notes']!,
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
              ),
          if (entry.metadata.containsKey('special_rules') &&
              entry.metadata['special_rules']!.isNotEmpty)
            _InfoBlock(
              label: 'Special Rules',
              content: entry.metadata['special_rules']!,
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
        ];

      case 'tables':
        return [
          _InfoBlock(label: 'Description', content: entry.description),
          if (entry.metadata.containsKey('table_data'))
            _TableBlock(
              content: entry.metadata['table_data']!,
              headers: entry.metadata['table_headers'],
            ),
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
    this.textColor,
  });

  final String label;
  final String content;
  final Color? color;
  final Color? textColor;

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
                color: textColor ?? theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentBlock extends StatelessWidget {
  const _EquipmentBlock({required this.entry});

  final ReferenceEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companion = getCompanionType(entry.id);

    if (companion == null) {
      return const SizedBox.shrink();
    }

    final equipment = <String>[
      for (final key in companion.allowedWeaponTypes)
        getBasicEquipment(key)?.name ?? key.replaceAll('_', ' '),
      for (final key in companion.allowedArmourTypes)
        getBasicEquipment(key)?.name ?? key.replaceAll('_', ' '),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Equipment',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            equipment.isEmpty
                ? Text(
                    'No equipment',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: equipment.map((name) {
                      return Chip(
                        label: Text(
                          name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _TableBlock extends StatelessWidget {
  const _TableBlock({required this.content, this.headers});

  final String content;
  final String? headers;

  @override
  Widget build(BuildContext context) {
    if (headers != null) {
      return _buildHeaderTable(context);
    }

    return _buildRollTable(context);
  }

  List<String> _dataLines() =>
      content.split('\n').where((l) => l.trim().isNotEmpty).toList();

  Widget _buildHeaderTable(BuildContext context) {
    final theme = Theme.of(context);
    final headerList = headers!.split('|');
    final columnCount = headerList.length;
    final lines = _dataLines();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          columnWidths: {
            for (var i = 0; i < columnCount; i++)
              i: i == columnCount - 1
                  ? const FlexColumnWidth()
                  : const IntrinsicColumnWidth(),
          },
          border: TableBorder(
            horizontalInside: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              children: headerList.map((h) {
                return _tableCell(h, isHeader: true, theme: theme);
              }).toList(),
            ),
            for (var i = 0; i < lines.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: i.isEven
                      ? Colors.transparent
                      : theme.colorScheme.surfaceContainerLow,
                ),
                children: [
                  for (final cell in lines[i].split('|'))
                    _tableCell(cell, theme: theme),
                  for (var j = lines[i].split('|').length; j < columnCount; j++)
                    _tableCell('', theme: theme),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRollTable(BuildContext context) {
    final theme = Theme.of(context);
    final lines = content.split('\n');
    final tableRows = <({String roll, String result})>[];
    final otherLines = <String>[];

    for (final line in lines) {
      final match = RegExp(r'^(\d+)(?:-(\d+)|\+)?:\s(.+)$').firstMatch(line);
      if (match != null) {
        final minRoll = int.parse(match.group(1)!);
        final maxRoll = match.group(2) != null ? int.parse(match.group(2)!) : minRoll;
        final isPlus = line.contains('+');
        final rollText = isPlus
            ? '$minRoll+'
            : (minRoll == maxRoll ? '$minRoll' : '$minRoll\u2013$maxRoll');
        tableRows.add((roll: rollText, result: match.group(3)!));
      } else {
        otherLines.add(line);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tableRows.isNotEmpty)
            _buildSimpleTable(
              context,
              const ['Roll', 'Result'],
              tableRows
                  .map((r) => [r.roll, r.result])
                  .toList(),
            ),
          if (tableRows.isNotEmpty && otherLines.isNotEmpty)
            const SizedBox(height: 12),
          ...otherLines.where((l) => l.isNotEmpty).map((line) {
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
          }),
        ],
      ),
    );
  }

  Widget _buildSimpleTable(
    BuildContext context,
    List<String> headerLabels,
    List<List<String>> rows,
  ) {
    final theme = Theme.of(context);
    final columnCount = headerLabels.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Table(
        columnWidths: {
          for (var i = 0; i < columnCount; i++)
            i: i == columnCount - 1
                ? const FlexColumnWidth()
                : const IntrinsicColumnWidth(),
        },
        border: TableBorder(
          horizontalInside: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            children: headerLabels.map((h) {
              return _tableCell(h, isHeader: true, theme: theme);
            }).toList(),
          ),
          for (var i = 0; i < rows.length; i++)
            TableRow(
              decoration: BoxDecoration(
                color: i.isEven
                    ? Colors.transparent
                    : theme.colorScheme.surfaceContainerLow,
              ),
              children: [
                for (final cell in rows[i])
                  _tableCell(cell, theme: theme),
                for (var j = rows[i].length; j < columnCount; j++)
                  _tableCell('', theme: theme),
              ],
            ),
        ],
      ),
    );
  }

  Widget _tableCell(
    String text, {
    bool isHeader = false,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: isHeader
            ? theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              )
            : theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
      ),
    );
  }
}
