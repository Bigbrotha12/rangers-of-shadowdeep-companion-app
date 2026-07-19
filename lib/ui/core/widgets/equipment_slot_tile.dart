import 'package:flutter/material.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class EquipmentSlotTile extends StatelessWidget {
  const EquipmentSlotTile({
    required this.item,
    required this.slotIndex,
    required this.totalSlots,
    required this.theme,
    required this.onUse,
    required this.onToggleActive,
    required this.onUnequip,
    super.key,
  });

  final RangerEquipmentWithName? item;
  final int slotIndex;
  final int totalSlots;
  final ThemeData theme;
  final void Function(RangerEquipmentWithName item)? onUse;
  final void Function(RangerEquipmentWithName item)? onToggleActive;
  final void Function(RangerEquipmentWithName item)? onUnequip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: item != null
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          radius: 16,
          child: Icon(
            item != null ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: item != null
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          item?.name ?? 'Empty Slot',
          style: TextStyle(
            fontWeight: item != null ? FontWeight.bold : null,
            color: item != null ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: item?.equipment.currentUses != null
            ? Text('Uses: ${item!.equipment.currentUses}')
            : null,
        trailing: item != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item!.equipment.currentUses != null &&
                      item!.equipment.currentUses! > 0 &&
                      onUse != null)
                    TextButton.icon(
                      icon: Icon(Icons.remove_circle_outline,
                          size: 24, color: theme.colorScheme.error),
                      label: Text('Use',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.error,
                          )),
                      onPressed: () => onUse!(item!),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  if (item!.equipment.currentUses != null &&
                      item!.equipment.currentUses! > 0)
                    const SizedBox(width: Spacing.md),
                  if (onToggleActive != null)
                    Switch(
                      value: item!.isActive,
                      onChanged: (_) => onToggleActive!(item!),
                    ),
                  if (onUnequip != null)
                    IconButton(
                      icon: const Icon(Icons.indeterminate_check_box, size: 20),
                      onPressed: () => onUnequip!(item!),
                      tooltip: 'Unequip',
                    ),
                ],
              )
            : null,
      ),
    );
  }
}

class InventoryItemTile extends StatelessWidget {
  const InventoryItemTile({
    required this.item,
    required this.theme,
    required this.onUse,
    required this.onEquip,
    required this.onRemove,
    this.canEquip = false,
    this.leading,
    this.showEquipButton = true,
    super.key,
  });

  final RangerEquipmentWithName item;
  final ThemeData theme;
  final void Function(RangerEquipmentWithName item)? onUse;
  final void Function(RangerEquipmentWithName item)? onEquip;
  final void Function(int itemId)? onRemove;
  final bool canEquip;
  final Widget? leading;
  final bool showEquipButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: ListTile(
        dense: true,
        leading: leading ??
            Icon(Icons.inventory_2,
                size: 20, color: theme.colorScheme.onSurfaceVariant),
        title: Text(item.name, style: theme.textTheme.bodyMedium),
        subtitle: item.equipment.currentUses != null
            ? Text('Uses: ${item.equipment.currentUses}',
                style: theme.textTheme.bodySmall)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.equipment.currentUses != null &&
                item.equipment.currentUses! > 0 &&
                onUse != null)
              TextButton.icon(
                icon: Icon(Icons.remove_circle_outline,
                    size: 24, color: theme.colorScheme.error),
                label: Text('Use',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.error,
                    )),
                onPressed: () => onUse!(item),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (item.equipment.currentUses != null &&
                item.equipment.currentUses! > 0)
              const SizedBox(width: Spacing.sm),
            if (showEquipButton && canEquip && onEquip != null)
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () => onEquip!(item),
                tooltip: 'Equip',
              ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => onRemove!(item.equipment.id),
                tooltip: 'Remove',
              ),
          ],
        ),
      ),
    );
  }
}
