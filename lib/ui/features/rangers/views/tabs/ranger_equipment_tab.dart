import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_utils.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_slot_tile.dart';
import 'package:rangers_mobile/ui/core/widgets/placeholder_image.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RangerEquipmentTab extends ConsumerWidget {
  const RangerEquipmentTab({
    required this.ranger,
    required this.rangerId,
    required this.onEquip,
    super.key,
  });

  final RangerDetail ranger;
  final int rangerId;
  final Future<void> Function(RangerEquipmentData item) onEquip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final equipped = List<RangerEquipmentWithName?>.generate(6, (i) {
      final matches = ranger.equipment.where((e) => e.slotIndex == i && e.equipment.equippedBy == 'ranger');
      return matches.isEmpty ? null : matches.first;
    });
    final inventory = ranger.equipment.where((e) =>
      e.slotIndex == null && (e.equipment.equippedBy == 'ranger' || e.equipment.equippedBy == 'pool')).toList();

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text('Equipment (${equipped.where((e) => e != null).length}/6 Slots)',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: Spacing.sm),
        ...List.generate(6, (i) => EquipmentSlotTile(
          item: equipped[i],
          slotIndex: i,
          totalSlots: 6,
          theme: theme,
          onUse: (item) async {
            final remaining = item.equipment.currentUses ?? 0;
            final confirmed = await showUseItemChargeDialog(context, item.name, remaining);
            if (confirmed) {
              await useItemCharge(ref, item.equipment.id, rangerId);
            }
          },
          onToggleActive: (item) => toggleItemActive(ref, item.equipment, rangerId),
          onUnequip: (item) => unequipItem(ref, item.equipment, rangerId),
        )),

        const SizedBox(height: Spacing.lg),

        Row(
          children: [
            Text('Inventory (${inventory.length})',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => showAddItemDialog(context, ref, rangerId, ranger.equipment),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item'),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        if (inventory.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: Text('No items in inventory.', style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
          )
        else
          ...inventory.map((item) => InventoryItemTile(
            item: item,
            theme: theme,
            leading: PlaceholderImage(
              assetPath: _getItemAssetPath(item.category),
              category: _getItemCategory(item.category),
              width: 32,
              height: 32,
            ),
            onUse: (item) async {
              final remaining = item.equipment.currentUses ?? 0;
              final confirmed = await showUseItemChargeDialog(context, item.name, remaining);
              if (confirmed) {
                await useItemCharge(ref, item.equipment.id, rangerId);
              }
            },
            canEquip: equipped.where((e) => e != null).length < 6,
            onEquip: (item) => onEquip(item.equipment),
            onRemove: (id) => removeItem(ref, id, rangerId),
          )),
      ],
    );
  }
}

String _getItemAssetPath(String category) {
  switch (category) {
    case 'basic_weapon':
    case 'magic_weapon':
      return 'assets/images/items/weapon.png';
    case 'basic_armour':
    case 'magic_armour':
      return 'assets/images/items/armour.png';
    case 'magic_item':
      return 'assets/images/items/magic_item.png';
    case 'herb_potion':
      return 'assets/images/items/herb_potion.png';
    case 'basic_gear':
      return 'assets/images/items/gear.png';
    default:
      return 'assets/images/items/gear.png';
  }
}

String _getItemCategory(String category) {
  switch (category) {
    case 'basic_weapon':
    case 'magic_weapon':
      return 'weapon';
    case 'basic_armour':
    case 'magic_armour':
      return 'armour';
    case 'magic_item':
      return 'magic_item';
    case 'herb_potion':
      return 'herb_potion';
    case 'basic_gear':
      return 'gear';
    default:
      return 'gear';
  }
}
