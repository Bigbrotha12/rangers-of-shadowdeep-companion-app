import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/reference_provider.dart';
import '../../../../data/services/rules_reference_service.dart';

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
    final subtitle = _getSubtitle();

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
                child: Column(
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
                ),
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

  String? _getSubtitle() {
    if (entry.metadata.containsKey('rp_cost')) {
      final stats = [
        'M${entry.metadata['move']}',
        'F+${entry.metadata['fight']}',
        'S+${entry.metadata['shoot']}',
        'A${entry.metadata['armour']}',
        'W+${entry.metadata['will']}',
        'H${entry.metadata['health']}',
      ];
      return 'RP ${entry.metadata['rp_cost']}  •  ${stats.join(' ')}';
    }
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
