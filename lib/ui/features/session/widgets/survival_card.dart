import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/services/post_game_service.dart' show SurvivalResult;
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_state.dart';

class SurvivalCard extends ConsumerStatefulWidget {
  final SurvivalTargetState target;
  final VoidCallback onRoll;
  final ValueChanged<int> onManualRoll;
  final VoidCallback onRollInjury;
  final ValueChanged<int> onManualInjuryRoll;

  const SurvivalCard({
    super.key,
    required this.target,
    required this.onRoll,
    required this.onManualRoll,
    required this.onRollInjury,
    required this.onManualInjuryRoll,
  });

  @override
  ConsumerState<SurvivalCard> createState() => SurvivalCardState();
}

class SurvivalCardState extends ConsumerState<SurvivalCard> {
  final _manualRollController = TextEditingController();
  final _manualInjuryController = TextEditingController();

  @override
  void dispose() {
    _manualRollController.dispose();
    _manualInjuryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = widget.target;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: target.isRanger ? theme.colorScheme.surfaceContainerHighest : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: target.isRanger ? theme.colorScheme.primary : theme.colorScheme.secondaryContainer,
                  child: Icon(target.isRanger ? Icons.person : Icons.pets, color: target.isRanger ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(target.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(target.isRanger ? 'Ranger' : 'Companion', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                if (target.result != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _outcomeColor(target.result!, theme).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _outcomeColor(target.result!, theme)),
                    ),
                    child: Text(_outcomeLabel(target.result!), style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: _outcomeColor(target.result!, theme))),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (target.result == null) ...[
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: widget.onRoll,
                    icon: const Icon(Icons.casino),
                    label: const Text('Roll d20'),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _manualRollController,
                      decoration: const InputDecoration(
                        labelText: 'Manual',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () {
                      final roll = int.tryParse(_manualRollController.text);
                      if (roll != null && roll >= 1 && roll <= 20) {
                        widget.onManualRoll(roll);
                      }
                    },
                    child: const Text('Set'),
                  ),
                ],
              ),
              if (target.isRanger)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Rangers add +1 to the roll', style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
                ),
            ],

            if (target.result != null) ...[
              OutcomeDetail(target: target, theme: theme),

              if (target.result == SurvivalResult.permanentInjury && target.injury == null) ...[
                const SizedBox(height: 12),
                const Divider(),
                Text('Roll on Permanent Injury Table (d20)', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: widget.onRollInjury,
                      icon: const Icon(Icons.casino),
                      label: const Text('Roll d20'),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _manualInjuryController,
                        decoration: const InputDecoration(
                          labelText: 'Manual',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () {
                        final roll = int.tryParse(_manualInjuryController.text);
                        if (roll != null && roll >= 1 && roll <= 20) {
                          widget.onManualInjuryRoll(roll);
                        }
                      },
                      child: const Text('Set'),
                    ),
                  ],
                ),
              ],

              if (target.injury != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusOrange(theme).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusOrange(theme)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.healing, color: statusOrange(theme)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(target.injury!.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: statusOrange(theme))),
                          Text(target.injury!.effect, style: theme.textTheme.bodySmall),
                        ],
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _outcomeColor(SurvivalResult result, ThemeData theme) {
    switch (result) {
      case SurvivalResult.dead: return theme.colorScheme.error;
      case SurvivalResult.permanentInjury: return statusOrange(theme);
      case SurvivalResult.badlyWounded: return statusAmber(theme);
      case SurvivalResult.closeCall: return statusBlue(theme);
      case SurvivalResult.fullRecovery: return statusGreen(theme);
    }
  }

  String _outcomeLabel(SurvivalResult result) {
    switch (result) {
      case SurvivalResult.dead: return 'DEAD';
      case SurvivalResult.permanentInjury: return 'PERMANENT INJURY';
      case SurvivalResult.badlyWounded: return 'BADLY WOUNDED';
      case SurvivalResult.closeCall: return 'CLOSE CALL';
      case SurvivalResult.fullRecovery: return 'FULL RECOVERY';
    }
  }
}

class OutcomeDetail extends StatelessWidget {
  final SurvivalTargetState target;
  final ThemeData theme;

  const OutcomeDetail({super.key, required this.target, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon(), color: _color()),
              const SizedBox(width: 12),
              Expanded(child: Text(
                _message(),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: _color()),
              )),
            ],
          ),
          if (target.survivalRoll != null) ...[
            const SizedBox(height: 6),
            Text(
              'd20: ${target.survivalRoll}${target.isRanger ? " (${target.survivalRollModified})" : ""}',
              style: theme.textTheme.bodySmall?.copyWith(color: _color()),
            ),
            if (target.injuryRoll != null)
              Text(
                'Injury d20: ${target.injuryRoll}',
                style: theme.textTheme.bodySmall?.copyWith(color: statusOrange(theme)),
              ),
          ],
        ],
      ),
    );
  }

  Color _color() {
    switch (target.result!) {
      case SurvivalResult.dead: return theme.colorScheme.error;
      case SurvivalResult.permanentInjury: return statusOrange(theme);
      case SurvivalResult.badlyWounded: return statusAmber(theme);
      case SurvivalResult.closeCall: return statusBlue(theme);
      case SurvivalResult.fullRecovery: return statusGreen(theme);
    }
  }

  IconData _icon() {
    switch (target.result!) {
      case SurvivalResult.dead: return Icons.dangerous;
      case SurvivalResult.permanentInjury: return Icons.healing;
      case SurvivalResult.badlyWounded: return Icons.warning;
      case SurvivalResult.closeCall: return Icons.shield;
      case SurvivalResult.fullRecovery: return Icons.check_circle;
    }
  }

  String _message() {
    switch (target.result!) {
      case SurvivalResult.dead:
        return target.isRanger
            ? 'Your ranger has fallen. Start a new campaign.'
            : 'The companion has died. All items are lost.';
      case SurvivalResult.permanentInjury:
        return 'Roll on the Permanent Injury Table to determine the injury.';
      case SurvivalResult.badlyWounded:
        return 'Starts next game at -5 Health.';
      case SurvivalResult.closeCall:
        return 'Escapes with only minor injuries. Loses all non-standard equipment.';
      case SurvivalResult.fullRecovery:
        return 'Returns next scenario at full Health.';
    }
  }
}
