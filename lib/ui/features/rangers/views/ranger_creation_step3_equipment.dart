import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/constants/basic_equipment.dart';
import '../view_models/ranger_creation_provider.dart';

class RangerCreationStep3Equipment extends ConsumerWidget {
  const RangerCreationStep3Equipment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rangerCreationProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Equipment Slots Display
          _EquipmentSlotsHeader(
            selected: state.selectedEquipment.length,
            max: maxStartingEquipmentItems,
          ),
          const SizedBox(height: 24),

          // Selected Equipment
          if (state.selectedEquipment.isNotEmpty) ...[
            Text(
              'Selected Equipment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _SelectedEquipmentList(
              selectedKeys: state.selectedEquipment,
            ),
            const SizedBox(height: 24),
          ],

          // Available Equipment
          Text(
            'Available Equipment (Free)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select up to $maxStartingEquipmentItems items from the Basic Equipment List.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _AvailableEquipmentList(
            selectedKeys: state.selectedEquipment,
          ),
        ],
      ),
    );
  }
}

class _EquipmentSlotsHeader extends StatelessWidget {
  const _EquipmentSlotsHeader({
    required this.selected,
    required this.max,
  });

  final int selected;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Equipment Slots: $selected / $max',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedEquipmentList extends ConsumerWidget {
  const _SelectedEquipmentList({required this.selectedKeys});

  final List<String> selectedKeys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedKeys.map((key) {
        final item = getBasicEquipment(key);
        if (item == null) return const SizedBox.shrink();

        return Chip(
          label: Text(item.name),
          deleteIcon: Icon(Icons.close, size: 18, color: theme.colorScheme.onPrimaryContainer),
          onDeleted: () {
            ref.read(rangerCreationProvider.notifier).toggleEquipment(key);
          },
          backgroundColor: theme.colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        );
      }).toList(),
    );
  }
}

class _AvailableEquipmentList extends ConsumerWidget {
  const _AvailableEquipmentList({required this.selectedKeys});

  final List<String> selectedKeys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canAddMore = selectedKeys.length < maxStartingEquipmentItems;

    return Card(
      child: Column(
        children: basicEquipmentList.map((item) {
          final isSelected = selectedKeys.contains(item.key);
          final canToggle = isSelected || canAddMore;

          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(item.name),
            subtitle: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.isTwoHanded)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '2H',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Checkbox(
                  value: isSelected,
                  onChanged: canToggle
                      ? (value) {
                          ref
                              .read(rangerCreationProvider.notifier)
                              .toggleEquipment(item.key);
                        }
                      : null,
                ),
              ],
            ),
            onTap: canToggle
                ? () {
                    ref
                        .read(rangerCreationProvider.notifier)
                        .toggleEquipment(item.key);
                  }
                : null,
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'weapon':
        return Icons.linear_scale;
      case 'armour':
        return Icons.shield;
      case 'gear':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }
}
