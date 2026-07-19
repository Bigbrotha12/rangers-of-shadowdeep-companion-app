import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';
import 'package:rangers_mobile/domain/services/stat_calculation_service.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RangerInjuriesTab extends ConsumerWidget {
  const RangerInjuriesTab({
    required this.ranger,
    required this.rangerId,
    super.key,
  });

  final RangerDetail ranger;
  final int rangerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final injuryKeys = ranger.permanentInjuryKeys;
    final statusEffectKeys = ranger.statusEffects;

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text('Permanent Injuries',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: Spacing.sm),
        if (injuryKeys.isEmpty && !ranger.ranger.notes.contains('[Injury]'))
          Card(child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Row(children: [
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
              const SizedBox(width: Spacing.md),
              const Text('No permanent injuries.'),
            ]),
          ))
        else ...[
          ...injuryKeys.map((key) {
            final injury = permanentInjuries.where((i) => i.key == key).firstOrNull;
            return Card(
              margin: const EdgeInsets.only(bottom: Spacing.xs),
              child: ListTile(
                leading: Icon(Icons.warning_amber, color: theme.colorScheme.error),
                title: Text(injury?.name ?? key.replaceAll('_', ' ')),
                subtitle: Text(injury?.effect ?? ''),
              ),
            );
          }),
          if (ranger.ranger.notes.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: Spacing.xs),
                    Text(ranger.ranger.notes, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ],

        const Divider(height: 32),

        Text('Active Status Effects',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: Spacing.sm),
        if (statusEffectKeys.isEmpty)
          Card(child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Text('No active status effects.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
          ))
        else
          ...statusEffectKeys.map((key) {
            final effect = getStatusEffect(key);
            return Card(
              margin: const EdgeInsets.only(bottom: Spacing.xs),
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

        const SizedBox(height: Spacing.lg),

        Text('Penalty Summary',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: Spacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              children: [
                _penaltyRow('Move', computeStatPenalty('move',
                  permanentInjuryKeys: injuryKeys,
                  statusEffectKeys: statusEffectKeys,
                ), theme),
                _penaltyRow('Fight', computeStatPenalty('fight',
                  permanentInjuryKeys: injuryKeys,
                  statusEffectKeys: statusEffectKeys,
                ), theme),
                _penaltyRow('Shoot', computeStatPenalty('shoot',
                  permanentInjuryKeys: injuryKeys,
                  statusEffectKeys: statusEffectKeys,
                ), theme),
                _penaltyRow('Will', computeStatPenalty('will',
                  permanentInjuryKeys: injuryKeys,
                  statusEffectKeys: statusEffectKeys,
                ), theme),
                _penaltyRow('Health', computeStatPenalty('health',
                  permanentInjuryKeys: injuryKeys,
                  statusEffectKeys: statusEffectKeys,
                ), theme),
              ],
            ),
          ),
        ),

        const SizedBox(height: Spacing.lg),

        Text('Active Special Rules',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: Spacing.sm),
        Builder(builder: (_) {
          final rules = getActiveSpecialRules(
            permanentInjuryKeys: injuryKeys,
            statusEffectKeys: statusEffectKeys,
          );
          if (rules.isEmpty) {
            return Text('None.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant));
          }
          return Column(
            children: rules.map((rule) => Card(
              margin: const EdgeInsets.only(bottom: Spacing.xs),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: Spacing.sm),
                    Expanded(child: Text(rule.replaceAll('_', ' '))),
                  ],
                ),
              ),
            )).toList(),
          );
        }),
      ],
    );
  }
}

Widget _penaltyRow(String label, int penalty, ThemeData theme) {
  final display = penalty >= 0 ? '+$penalty' : '$penalty';
  final isNegative = penalty < 0;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
    child: Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
        Text(display, style: TextStyle(
          color: isNegative ? theme.colorScheme.error : theme.colorScheme.tertiary,
          fontWeight: FontWeight.bold,
        )),
      ],
    ),
  );
}
