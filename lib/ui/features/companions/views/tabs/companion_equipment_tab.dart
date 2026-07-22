import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/domain/constants/basic_equipment.dart';
import 'package:rangers_mobile/domain/constants/magic_items.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_utils.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_slot_tile.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class CompanionEquipmentTab extends ConsumerStatefulWidget {
  const CompanionEquipmentTab({
    required this.rangerId,
    required this.companionId,
    required this.type,
    super.key,
  });

  final int rangerId;
  final int companionId;
  final CompanionTypeDefinition type;

  @override
  ConsumerState<CompanionEquipmentTab> createState() => CompanionEquipmentTabState();
}

class CompanionEquipmentTabState extends ConsumerState<CompanionEquipmentTab> {
  String _safeDbKey(EquipmentData e) {
    try {
      return e.itemKey;
    } on Exception catch (_) {
      return '';
    }
  }

  bool _canCompanionEquip(String itemKey, String category) {
    if (itemKey.isEmpty) return false;
    final type = widget.type;
    return switch (category) {
      'basic_weapon' => type.allowedWeaponTypes.contains(itemKey),
      'magic_weapon' => type.allowedWeaponTypes.contains(
        getMagicItem(itemKey)?.replacesWeaponType ?? itemKey),
      'basic_armour' => type.allowedArmourTypes.contains(itemKey),
      'magic_armour' => type.allowedArmourTypes.contains(
        getMagicItem(itemKey)?.replacesArmourType ?? itemKey),
      'basic_gear' => itemKey == 'shield'
        ? type.allowedArmourTypes.contains('shield')
        : true,
      _ => true,
    };
  }

  Future<void> _equipItem(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    final equipment = await repo.getEquipmentById(item.equipmentId);
    if (equipment == null) return;

    final itemKey = _safeDbKey(equipment);
    if (itemKey.isEmpty) return;
    if (!_canCompanionEquip(itemKey, equipment.category)) return;

    final ranger = await ref.read(rangerDetailProvider(widget.rangerId).future);
    if (ranger == null) return;

    final companionEquipped = ranger.equipment
      .where((e) => e.slotIndex != null)
      .where((e) => e.equipment.companionId == widget.companionId)
      .toList();
    final usedSlots = companionEquipped.map((e) => e.slotIndex!).toSet();

    final magicItem = getMagicItem(itemKey);
    final replacesType = magicItem?.replacesWeaponType ?? magicItem?.replacesArmourType;
    if (replacesType != null) {
      final toReplace = companionEquipped.where((e) => e.itemKey == replacesType).toList();
      for (final old in toReplace) {
        usedSlots.remove(old.slotIndex);
        await repo.updateRangerEquipment(RangerEquipmentCompanion(
          id: Value(old.equipment.id),
          slotIndex: const Value(null),
          equippedBy: const Value('pool'),
        ));
      }
    }

    for (int i = 0; i < maxCompanionEquipmentSlots; i++) {
      if (!usedSlots.contains(i)) {
        await repo.updateRangerEquipment(RangerEquipmentCompanion(
          id: Value(item.id),
          slotIndex: Value(i),
          equippedBy: const Value('companion'),
          companionId: Value(widget.companionId),
        ));
        ref.invalidate(rangerDetailProvider(widget.rangerId));
        return;
      }
    }
  }

  Future<void> _unequipItem(RangerEquipmentData item) async {
    await unequipItem(ref, item, widget.rangerId);
  }

  Future<void> _removeItem(int itemId) async {
    await removeItem(ref, itemId, widget.rangerId);
  }

  Future<void> _toggleActive(RangerEquipmentData item) async {
    await toggleItemActive(ref, item, widget.rangerId);
  }

  Future<void> _useItem(RangerEquipmentData item) async {
    await useItemCharge(ref, item.id, widget.rangerId);
  }

  Future<void> _confirmAndUseItem(BuildContext context, RangerEquipmentData item, String itemName) async {
    final remaining = item.currentUses ?? 0;
    final confirmed = await showUseItemChargeDialog(context, itemName, remaining);
    if (confirmed) {
      await _useItem(item);
    }
  }

  String _safeItemKey(EquipmentData e) {
    try {
      return e.itemKey;
    } on Exception catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangerAsync = ref.watch(rangerDetailProvider(widget.rangerId));
    final type = widget.type;

    final standardWeaponKeys = type.allowedWeaponTypes;
    final standardArmourKeys = type.allowedArmourTypes;

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) {
          return const Center(child: Text('Ranger not found'));
        }

        final companionItems = ranger.equipment
          .where((e) => e.equipment.companionId == widget.companionId || e.equipment.equippedBy == 'pool')
          .toList();

        final equipped = List<RangerEquipmentWithName?>.generate(
          maxCompanionEquipmentSlots,
          (i) {
            final matches = companionItems.where((e) => e.slotIndex == i);
            return matches.isEmpty ? null : matches.first;
          },
        );
        final inventory = companionItems.where((e) => e.slotIndex == null).toList();

        final replacedKeys = <String>{};
        for (final slot in equipped) {
          if (slot == null) continue;
          if (slot.itemKey.isEmpty) continue;
          final magicItem = getMagicItem(slot.itemKey);
          if (magicItem != null) {
            final r = magicItem.replacesWeaponType ?? magicItem.replacesArmourType;
            if (r != null) replacedKeys.add(r);
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (standardWeaponKeys.isNotEmpty || standardArmourKeys.isNotEmpty) ...[
              Text('Standard Equipment (always carried)',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...standardWeaponKeys.map((key) {
                final name = getBasicEquipment(key)?.name ?? key;
                return _standardItemTile(
                  theme: theme,
                  name: name,
                  replaced: replacedKeys.contains(key),
                );
              }),
              ...standardArmourKeys.map((key) {
                final name = getBasicEquipment(key)?.name ?? key;
                return _standardItemTile(
                  theme: theme,
                  name: name,
                  replaced: replacedKeys.contains(key),
                );
              }),
              const SizedBox(height: 16),
            ],

            Text('Additional Slots (${equipped.where((e) => e != null).length}/$maxCompanionEquipmentSlots)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(maxCompanionEquipmentSlots, (i) => EquipmentSlotTile(
              item: equipped[i],
              slotIndex: i,
              totalSlots: maxCompanionEquipmentSlots,
              theme: theme,
              onUse: (item) => _confirmAndUseItem(context, item.equipment, item.name),
              onToggleActive: (item) => _toggleActive(item.equipment),
              onUnequip: (item) => _unequipItem(item.equipment),
            )),

            const SizedBox(height: 16),

            Row(
              children: [
                Text('Inventory (${inventory.length})',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (inventory.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('No items in inventory.', style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
              )
            else
              ...inventory.map((item) {
                final canEquip = _canCompanionEquip(item.itemKey, item.category) 
                  && equipped.where((e) => e != null).length < maxCompanionEquipmentSlots;
                return InventoryItemTile(
                  item: item,
                  theme: theme,
                  onUse: (item) => _confirmAndUseItem(context, item.equipment, item.name),
                  canEquip: canEquip,
                  onEquip: (item) => _equipItem(item.equipment),
                  onRemove: _removeItem,
                );
              }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _standardItemTile({
    required ThemeData theme,
    required String name,
    required bool replaced,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            replaced ? Icons.swap_horiz : Icons.check_circle,
            size: 18,
            color: replaced ? theme.colorScheme.tertiary : theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              decoration: replaced ? TextDecoration.lineThrough : null,
              color: replaced ? theme.colorScheme.onSurfaceVariant : null,
            ),
          ),
          if (replaced) ...[
            const SizedBox(width: 4),
            Text(
              '(replaced)',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog() async {
    final ranger = await ref.read(rangerDetailProvider(widget.rangerId).future);
    if (ranger == null) return;
    if (!mounted) return;

    showAddItemDialog(
      context,
      ref,
      widget.rangerId,
      ranger.equipment,
      additionalFilter: (e) => _canCompanionEquip(_safeItemKey(e), e.category),
    );
  }
}
