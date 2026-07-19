import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';

class CompanionSkillsTab extends StatelessWidget {
  const CompanionSkillsTab({
    required this.companion,
    required this.type,
    super.key,
  });

  final CompanionData companion;
  final CompanionTypeDefinition type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final skillEntries = skills.map((skill) {
      final baseValue = type.baseSkills[skill.key] ?? 0;
      final customValue = companion.customSkills[skill.key] ?? 0;
      return (skill: skill, value: baseValue + customValue);
    }).where((e) => e.value > 0).toList();

    if (skillEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No skills',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This companion has no skills yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skillEntries.length,
      itemBuilder: (context, index) {
        final entry = skillEntries[index];
        final skill = entry.skill;
        final value = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
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
                '+$value',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            onTap: () => context.push(
              '/reference/skills/${skill.key}',
            ),
          ),
        );
      },
    );
  }
}
