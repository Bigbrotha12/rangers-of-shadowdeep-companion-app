import 'package:flutter/material.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/spells.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RangerAbilitiesTab extends StatelessWidget {
  const RangerAbilitiesTab({
    required this.ranger,
    super.key,
  });

  final RangerDetail ranger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ranger.heroicAbilities.isEmpty && ranger.spells.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'No Abilities',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'No heroic abilities or spells selected.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ranger.heroicAbilities.isNotEmpty) ...[
            Text(
              'Heroic Abilities',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            ...ranger.heroicAbilities.map((ability) {
              final data = heroicAbilities.firstWhere(
                (a) => a.key == ability.abilityKey,
                orElse: () => heroicAbilities.first,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: Spacing.sm),
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(data.name),
                  subtitle: Text(
                    data.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
            const SizedBox(height: Spacing.lg),
          ],
          if (ranger.spells.isNotEmpty) ...[
            Text(
              'Spells',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            ...ranger.spells.map((spell) {
              final data = spells.firstWhere(
                (s) => s.key == spell.abilityKey,
                orElse: () => spells.first,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: Spacing.sm),
                child: ListTile(
                  leading: Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.tertiary,
                  ),
                  title: Text(data.name),
                  subtitle: Text(
                    data.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
