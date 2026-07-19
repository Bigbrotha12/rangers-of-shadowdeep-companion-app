import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_provider.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_state.dart';

class TreasureCountSetup extends StatefulWidget {
  final PostGameNotifier notifier;
  final ThemeData theme;

  const TreasureCountSetup({super.key, required this.notifier, required this.theme});

  @override
  State<TreasureCountSetup> createState() => _TreasureCountSetupState();
}

class _TreasureCountSetupState extends State<TreasureCountSetup> {
  final _controller = TextEditingController(text: '1');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How many treasure tokens were secured?', style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Treasure',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    final count = int.tryParse(_controller.text);
                    if (count != null && count > 0) {
                      widget.notifier.setTreasureCount(count);
                    }
                  },
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TreasurePendingCard extends StatefulWidget {
  final int index;
  final ThemeData theme;
  final VoidCallback onRoll;
  final void Function(int main, int sub) onManualRoll;

  const TreasurePendingCard({
    super.key,
    required this.index,
    required this.theme,
    required this.onRoll,
    required this.onManualRoll,
  });

  @override
  State<TreasurePendingCard> createState() => _TreasurePendingCardState();
}

class _TreasurePendingCardState extends State<TreasurePendingCard> {
  final _mainController = TextEditingController();
  final _subController = TextEditingController();

  @override
  void dispose() {
    _mainController.dispose();
    _subController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.theme.colorScheme.tertiaryContainer,
                  child: Text('${widget.index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Treasure ${widget.index + 1}', style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                FilledButton.tonalIcon(
                  onPressed: widget.onRoll,
                  icon: const Icon(Icons.casino),
                  label: const Text('Roll d20'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text('Manual Roll:', style: widget.theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _mainController,
                    decoration: const InputDecoration(
                      hintText: '1-20',
                      labelText: 'Main',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _subController,
                    decoration: const InputDecoration(
                      hintText: '1-20',
                      labelText: 'Sub',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: () {
                    final main = int.tryParse(_mainController.text);
                    final sub = int.tryParse(_subController.text);
                    if (main != null && sub != null && main >= 1 && main <= 20 && sub >= 1 && sub <= 20) {
                      widget.onManualRoll(main, sub);
                    }
                  },
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TreasureResultCard extends ConsumerWidget {
  final TreasureResultState result;
  final int index;
  final ThemeData theme;

  const TreasureResultCard({
    super.key,
    required this.result,
    required this.index,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _categoryColor().withValues(alpha: 0.2),
                  child: Icon(_categoryIcon(), color: _categoryColor(), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(result.categoryName, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _categoryColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('#${result.treasureIndex + 1}', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                RollChip(label: 'Main', roll: result.mainRoll, theme: theme),
                const SizedBox(width: 8),
                RollChip(label: 'Sub', roll: result.subRoll, theme: theme),
              ],
            ),

            if (result.category == 'gold' && !result.isGoldChoiceMade) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text('Choose reward:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(postGameProvider.notifier).setTreasureGoldChoice(index, true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                      ),
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('+10 XP'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(postGameProvider.notifier).setTreasureGoldChoice(index, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                      ),
                      icon: const Icon(Icons.people, size: 18),
                      label: const Text('+1 PP to Companion'),
                    ),
                  ),
                ],
              ),
            ],
            if (result.isGoldChoiceMade) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusGreen(theme).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: statusGreen(theme), size: 18),
                    const SizedBox(width: 8),
                    Text(result.goldChoseXp ? '+10 XP applied' : '+1 PP awarded to companion',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: statusGreen(theme))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _categoryColor() {
    switch (result.category) {
      case 'gold': return statusAmber(theme);
      case 'herb_potion': return statusGreen(theme);
      case 'weapon_armour': return statusBlue(theme);
      case 'magic_item': return statusPurple(theme);
      default: return statusGrey(theme);
    }
  }

  IconData _categoryIcon() {
    switch (result.category) {
      case 'gold': return Icons.monetization_on;
      case 'herb_potion': return Icons.medication;
      case 'weapon_armour': return Icons.shield;
      case 'magic_item': return Icons.auto_awesome;
      default: return Icons.inventory_2;
    }
  }
}

class RollChip extends StatelessWidget {
  final String label;
  final int roll;
  final ThemeData theme;

  const RollChip({super.key, required this.label, required this.roll, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $roll', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}
