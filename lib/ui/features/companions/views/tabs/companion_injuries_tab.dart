import 'package:flutter/material.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';

class CompanionInjuriesTab extends StatelessWidget {
  const CompanionInjuriesTab({required this.companion, super.key});

  final CompanionData companion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Permanent Injuries',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (companion.permanentInjuries.isEmpty)
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('No permanent injuries.'),
            ]),
          ))
        else
          ...companion.permanentInjuries.map((key) {
            final injury = permanentInjuries.where((i) => i.key == key).firstOrNull;
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: Icon(Icons.warning_amber, color: theme.colorScheme.error),
                title: Text(injury?.name ?? key.replaceAll('_', ' ')),
                subtitle: Text(injury?.effect ?? ''),
              ),
            );
          }),

        const Divider(height: 32),

        Text('Active Status Effects',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (companion.statusEffects.isEmpty)
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No active status effects.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
          ))
        else
          ...companion.statusEffects.map((key) {
            final effect = getStatusEffect(key);
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: Icon(
                  effect?.category == StatusEffectCategory.positive
                    ? Icons.arrow_upward : Icons.arrow_downward,
                  color: effect?.category == StatusEffectCategory.positive
                    ? theme.colorScheme.tertiary : theme.colorScheme.error,
                ),
                title: Text(effect?.name ?? key),
                subtitle: Text(effect?.description ?? ''),
              ),
            );
          }),
      ],
    );
  }
}
