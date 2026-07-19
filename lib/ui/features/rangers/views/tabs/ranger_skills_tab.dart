import 'package:flutter/material.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RangerSkillsTab extends StatelessWidget {
  const RangerSkillsTab({
    required this.ranger,
    super.key,
  });

  final RangerDetail ranger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ranger.skillBonuses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'No Skill Bonuses',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'No skill bonuses assigned during creation.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.lg),
      itemCount: ranger.skillBonuses.length,
      itemBuilder: (context, index) {
        final skillBonus = ranger.skillBonuses[index];
        final skill = skills.firstWhere(
          (s) => s.key == skillBonus.skillKey,
          orElse: () => skills.first,
        );

        return ListTile(
          title: Text(skill.name),
          subtitle: Text(
            skill.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '+${skillBonus.value}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        );
      },
    );
  }
}
