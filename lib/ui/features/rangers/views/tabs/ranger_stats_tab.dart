import 'package:flutter/material.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/core/widgets/stat_display.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RangerStatsTab extends StatelessWidget {
  const RangerStatsTab({
    required this.ranger,
    required this.statModifiers,
    this.onEditNotes,
    super.key,
  });

  final RangerDetail ranger;
  final Map<String, int> statModifiers;
  final VoidCallback? onEditNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ranger.ranger;

    int effective(String key, int base) {
      final mod = statModifiers[key];
      return mod != null ? base + mod : base;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Center(
            child: Wrap(
              spacing: Spacing.lg,
              runSpacing: Spacing.md,
              alignment: WrapAlignment.center,
              children: [
                StatDisplay(label: 'Move', baseValue: r.move, effectiveValue: effective('move', r.move)),
                StatDisplay(label: 'Fight', baseValue: r.fight, effectiveValue: effective('fight', r.fight)),
                StatDisplay(label: 'Shoot', baseValue: r.shoot, effectiveValue: effective('shoot', r.shoot)),
                StatDisplay(label: 'Armour', baseValue: r.armour, effectiveValue: effective('armour', r.armour)),
                StatDisplay(label: 'Will', baseValue: r.will, effectiveValue: effective('will', r.will)),
                StatDisplay(
                  label: 'Health',
                  baseValue: r.health,
                  effectiveValue: r.currentHealth,
                ),
                StatDisplay(
                  label: 'Damage',
                  baseValue: statModifiers['damage'] ?? 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Text(
            'Recruitment Points',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${r.baseRecruitmentPoints}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  'RP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Row(
            children: [
              Text(
                'Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  r.notes.isEmpty ? Icons.add : Icons.edit,
                  size: 20,
                ),
                onPressed: onEditNotes,
                tooltip: r.notes.isEmpty ? 'Add note' : 'Edit note',
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          if (r.notes.isNotEmpty)
            Text(
              r.notes,
              style: theme.textTheme.bodyMedium,
            )
          else
            Text(
              'No notes added.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
