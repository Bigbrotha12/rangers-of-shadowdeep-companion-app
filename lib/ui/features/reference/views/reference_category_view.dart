import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/data/services/rules_reference_service.dart';
import 'package:rangers_mobile/ui/core/widgets/stat_display.dart';
import 'package:rangers_mobile/ui/features/reference/view_models/reference_provider.dart';

class ReferenceCategoryView extends ConsumerWidget {
  const ReferenceCategoryView({super.key, required this.categoryKey});

  final String categoryKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(referenceCategoryEntriesProvider(categoryKey));
    final favoriteIds = ref.watch(referenceFavoriteIdsProvider);
    final category = referenceCategories.where((c) => c.key == categoryKey);

    final title = category.isNotEmpty
        ? category.first.label
        : categoryKey.replaceAll('_', ' ');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isFav = favoriteIds.contains(entry.id);
          return _ReferenceEntryCard(
            entry: entry,
            isFavorite: isFav,
            onTap: () {
              context.push('/reference/$categoryKey/${entry.id}');
            },
            onToggleFavorite: () {
              ref
                  .read(referenceFavoriteIdsProvider.notifier)
                  .toggle(entry.id);
            },
          );
        },
      ),
    );
  }
}

class _ReferenceEntryCard extends StatelessWidget {
  const _ReferenceEntryCard({
    required this.entry,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final ReferenceEntry entry;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompanion = entry.metadata.containsKey('rp_cost');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: isCompanion
                    ? _CompanionContent(entry: entry, theme: theme)
                    : _DefaultContent(entry: entry, theme: theme),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFavorite
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultContent extends StatelessWidget {
  const _DefaultContent({required this.entry, required this.theme});

  final ReferenceEntry entry;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  String? _subtitle() {
    if (entry.metadata.containsKey('max_uses')) {
      return '${entry.metadata['max_uses']} uses';
    }
    if (entry.metadata.containsKey('table_data')) {
      return entry.metadata['table_data']!.split('\n').first;
    }
    return entry.description.length > 120
        ? '${entry.description.substring(0, 120)}...'
        : entry.description;
  }
}

class _CompanionContent extends StatelessWidget {
  const _CompanionContent({required this.entry, required this.theme});

  final ReferenceEntry entry;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'RP ${entry.metadata['rp_cost']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        StatTable(
          labels: const ['M', 'F', 'S', 'A', 'W', 'H'],
          values: [
            int.parse(entry.metadata['move']!),
            int.parse(entry.metadata['fight']!),
            int.parse(entry.metadata['shoot']!),
            int.parse(entry.metadata['armour']!),
            int.parse(entry.metadata['will']!),
            int.parse(entry.metadata['health']!),
          ],
        ),
      ],
    );
  }
}
