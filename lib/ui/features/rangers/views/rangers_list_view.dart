import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/rangers_provider.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/placeholder_image.dart';
import '../../../core/widgets/stat_display.dart';

class RangersListView extends ConsumerWidget {
  const RangersListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangersAsync = ref.watch(rangersListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rangers'),
      ),
      body: rangersAsync.when(
        data: (rangers) {
          if (rangers.isEmpty) {
            return EmptyState(
              icon: Icons.person_add,
              title: 'No Rangers Yet',
              message: 'Create your first ranger to begin your adventure.',
              action: FilledButton.icon(
                onPressed: () => context.push('/rangers/create'),
                icon: const Icon(Icons.add),
                label: const Text('Create Ranger'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rangers.length,
            itemBuilder: (context, index) {
              final ranger = rangers[index];
              return _RangerCard(ranger: ranger);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading rangers',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'rangers_fab',
        onPressed: () => context.push('/rangers/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RangerCard extends StatelessWidget {
  const _RangerCard({required this.ranger});

  final dynamic ranger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/rangers/${ranger.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PlaceholderImage(
                    assetPath: 'assets/images/rangers/default_ranger.png',
                    category: 'ranger',
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ranger.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Level ${ranger.level} | XP: ${ranger.experiencePoints}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatTable(
                    labels: const ['M', 'F', 'S', 'A', 'W', 'H'],
                    values: [ranger.move, ranger.fight, ranger.shoot, ranger.armour, ranger.will, ranger.health],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (ranger.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  ranger.notes,
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
      ),
    );
  }
}
