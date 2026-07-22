import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';

class CompanionInjuriesTab extends ConsumerStatefulWidget {
  const CompanionInjuriesTab({required this.companion, super.key});

  final CompanionData companion;

  @override
  ConsumerState<CompanionInjuriesTab> createState() => _CompanionInjuriesTabState();
}

class _CompanionInjuriesTabState extends ConsumerState<CompanionInjuriesTab> {
  @override
  Widget build(BuildContext context) {
    final companion = widget.companion;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
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
                trailing: IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.error),
                  tooltip: 'Remove Status Effect',
                  onPressed: () {
                    ref.read(companionProvider(companion.id).notifier)
                        .removeStatusEffect(key);
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showAddInjurySheet(BuildContext context) {
    final companion = widget.companion;
    final theme = Theme.of(context);
    final available = permanentInjuries
        .where((i) => canApplyInjury(companion.permanentInjuries, i.key))
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
        padding: const EdgeInsets.all(16),
        children: [
          Text('Add Permanent Injury',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...available.map((injury) => ListTile(
            leading: Icon(Icons.warning_amber, color: theme.colorScheme.error),
            title: Text(injury.name),
            subtitle: Text(injury.effect),
            onTap: () {
              Navigator.pop(ctx);
              ref.read(companionProvider(companion.id).notifier)
                  .addPermanentInjury(injury.key);
            },
          )),
        ],
      ),
    );
  }

  void _showAddStatusEffectSheet(BuildContext context) {
    final companion = widget.companion;
    final theme = Theme.of(context);
    final available = statusEffects
        .where((e) => !companion.statusEffects.contains(e.key))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Add Status Effect',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...available.map((effect) => ListTile(
            leading: Icon(
              effect.category == StatusEffectCategory.positive
                ? Icons.arrow_upward : Icons.arrow_downward,
              color: effect.category == StatusEffectCategory.positive
                ? theme.colorScheme.tertiary : theme.colorScheme.error,
            ),
            title: Text(effect.name),
            subtitle: Text(effect.description),
            onTap: () {
              Navigator.pop(ctx);
              ref.read(companionProvider(companion.id).notifier)
                  .addStatusEffect(effect.key);
            },
          )),
        ],
      ),
    );
  }
}
