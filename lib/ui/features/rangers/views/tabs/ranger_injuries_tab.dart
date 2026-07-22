import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';
import 'package:rangers_mobile/domain/services/stat_calculation_service.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RangerInjuriesTab extends ConsumerStatefulWidget {
  const RangerInjuriesTab({
    required this.ranger,
    required this.rangerId,
    super.key,
  });

  final RangerDetail ranger;
  final int rangerId;

  @override
  ConsumerState<RangerInjuriesTab> createState() => _RangerInjuriesTabState();
}

class _RangerInjuriesTabState extends ConsumerState<RangerInjuriesTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final injuryKeys = widget.ranger.permanentInjuryKeys;
    final statusEffectKeys = widget.ranger.statusEffects;

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Permanent Injuries',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add Permanent Injury',
              onPressed: () => _showAddInjurySheet(context),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        if (injuryKeys.isEmpty && !widget.ranger.ranger.notes.contains('[Injury]'))
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
                trailing: IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.error),
                  tooltip: 'Remove Injury',
                  onPressed: () => _removeInjury(key),
                ),
              ),
            );
          }),
          if (widget.ranger.ranger.notes.isNotEmpty) ...[
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
                    Text(widget.ranger.ranger.notes, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ],

        const Divider(height: 32),

        Row(
          children: [
            Expanded(
              child: Text('Active Status Effects',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add Status Effect',
              onPressed: () => _showAddStatusEffectSheet(context),
            ),
          ],
        ),
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
                trailing: IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.error),
                  tooltip: 'Remove Status Effect',
                  onPressed: () => _removeStatusEffect(key),
                ),
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

  void _showAddInjurySheet(BuildContext context) {
    final injuryKeys = widget.ranger.permanentInjuryKeys;
    final available = permanentInjuries
        .where((i) => canApplyInjury(injuryKeys, i.key))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All permanent injuries already applied.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Text('Add Permanent Injury',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...available.map((injury) => ListTile(
            leading: Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.error),
            title: Text(injury.name),
            subtitle: Text(injury.effect),
            onTap: () {
              Navigator.pop(ctx);
              _addInjury(injury.key);
            },
          )),
        ],
      ),
    );
  }

  Future<void> _addInjury(String injuryKey) async {
    final repo = ref.read(rangerRepositoryProvider);
    final notes = widget.ranger.ranger.notes;
    final updatedNotes = notes.isEmpty
        ? '[Injury] $injuryKey'
        : '$notes\n[Injury] $injuryKey';
    await repo.updateRangerFields(widget.rangerId, RangersCompanion(
      notes: Value(updatedNotes),
      updatedAt: Value(DateTime.now()),
    ));
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _removeInjury(String injuryKey) async {
    final repo = ref.read(rangerRepositoryProvider);
    final notes = widget.ranger.ranger.notes;
    final updatedNotes = notes
        .replaceAll('[Injury] $injuryKey', '')
        .replaceAll('\n\n', '\n')
        .trim();
    await repo.updateRangerFields(widget.rangerId, RangersCompanion(
      notes: Value(updatedNotes),
      updatedAt: Value(DateTime.now()),
    ));
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  void _showAddStatusEffectSheet(BuildContext context) {
    final currentKeys = widget.ranger.statusEffects;
    final available = statusEffects
        .where((e) => !currentKeys.contains(e.key))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Text('Add Status Effect',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...available.map((effect) => ListTile(
            leading: Icon(
              effect.category == StatusEffectCategory.positive
                ? Icons.arrow_upward : Icons.arrow_downward,
              color: effect.category == StatusEffectCategory.positive
                ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error,
            ),
            title: Text(effect.name),
            subtitle: Text(effect.description),
            onTap: () {
              Navigator.pop(ctx);
              _addStatusEffect(effect.key);
            },
          )),
        ],
      ),
    );
  }

  Future<void> _addStatusEffect(String effectKey) async {
    final repo = ref.read(rangerRepositoryProvider);
    final current = widget.ranger.statusEffects;
    await repo.setRangerStatusEffects(widget.rangerId, [...current, effectKey]);
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _removeStatusEffect(String effectKey) async {
    final repo = ref.read(rangerRepositoryProvider);
    final updated = widget.ranger.statusEffects.where((k) => k != effectKey).toList();
    await repo.setRangerStatusEffects(widget.rangerId, updated);
    ref.invalidate(rangerDetailProvider(widget.rangerId));
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
