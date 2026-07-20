import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

Map<String, int> computeEquipmentModifiers(
  List<RangerEquipmentWithName> items, {
  bool equippedOnly = false,
}) {
  const effectMappings = {
    'armour_bonus': 'armour',
    'fight_bonus': 'fight',
    'fight_penalty': 'fight',
    'shoot_bonus': 'shoot',
    'will_bonus': 'will',
    'will_penalty': 'will',
    'move_bonus': 'move',
    'move_penalty': 'move',
    'damage_modifier': 'damage',
  };

  final stats = <String, int>{};
  for (final item in items) {
    if (!item.isActive) continue;
    if (equippedOnly && item.slotIndex == null) continue;
    try {
      final effects = item.effects;
      if (effects.isEmpty) continue;
      final parsed = Map<String, dynamic>.from(
        const JsonDecoder().convert(effects) as Map,
      );
      for (final entry in effectMappings.entries) {
        final mod = parsed[entry.key] as int?;
        if (mod != null) {
          stats.update(entry.value, (v) => v + mod, ifAbsent: () => mod);
        }
      }
    } on FormatException catch (_) {
      // Graceful degradation: invalid effects JSON treated as empty
    }
  }
  return stats;
}

Future<bool> showUseItemChargeDialog(
  BuildContext context,
  String itemName,
  int remaining,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Use Item Charge'),
      content: Text(
        remaining <= 1
            ? 'Use $itemName? This will consume the item.'
            : 'Use one charge of $itemName?\n\n$remaining charges remaining.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Use'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

Future<void> toggleItemActive(
  WidgetRef ref,
  RangerEquipmentData item,
  int rangerId,
) async {
  final repo = ref.read(rangerRepositoryProvider);
  await repo.updateRangerEquipment(RangerEquipmentCompanion(
    id: Value(item.id),
    isActive: Value(!item.isActive),
  ));
  ref.invalidate(rangerDetailProvider(rangerId));
}

Future<void> unequipItem(
  WidgetRef ref,
  RangerEquipmentData item,
  int rangerId,
) async {
  final repo = ref.read(rangerRepositoryProvider);
  await repo.updateRangerEquipment(RangerEquipmentCompanion(
    id: Value(item.id),
    slotIndex: const Value(null),
    equippedBy: const Value('pool'),
  ));
  ref.invalidate(rangerDetailProvider(rangerId));
}

Future<void> removeItem(
  WidgetRef ref,
  int itemId,
  int rangerId,
) async {
  final repo = ref.read(rangerRepositoryProvider);
  await repo.deleteRangerEquipment(itemId);
  ref.invalidate(rangerDetailProvider(rangerId));
}

Future<void> addItem(
  WidgetRef ref,
  int rangerId,
  int equipmentId,
) async {
  final repo = ref.read(rangerRepositoryProvider);
  final equipment = await repo.getEquipmentById(equipmentId);
  await repo.insertRangerEquipment(RangerEquipmentCompanion.insert(
    rangerId: rangerId,
    equipmentId: equipmentId,
    equippedBy: const Value('pool'),
    currentUses: equipment?.hasUses == true
        ? Value(equipment!.maxUses)
        : const Value(null),
  ));
  ref.invalidate(rangerDetailProvider(rangerId));
}

Future<void> useItemCharge(
  WidgetRef ref,
  int equipmentId,
  int rangerId,
) async {
  final repo = ref.read(rangerRepositoryProvider);
  await repo.useEquipmentCharge(equipmentId);
  ref.invalidate(rangerDetailProvider(rangerId));
}

String _categoryLabel(String category) {
  return switch (category) {
    'basic_weapon' => 'Basic Weapon',
    'basic_armour' => 'Basic Armour',
    'basic_gear' => 'Basic Gear',
    'magic_weapon' => 'Magic Weapon',
    'magic_armour' => 'Magic Armour',
    'magic_item' => 'Magic Item',
    'herb_potion' => 'Herb or Potion',
    _ => category,
  };
}

Future<void> showAddItemDialog(
  BuildContext context,
  WidgetRef ref,
  int rangerId,
  List<RangerEquipmentWithName> equipment, {
  bool Function(EquipmentData e)? additionalFilter,
}) async {
  final repo = ref.read(rangerRepositoryProvider);
  final allEquipment = await repo.getAllEquipment();
  final ownedIds = equipment.map((e) => e.equipment.equipmentId).toSet();

  var eligible = allEquipment.where((e) => !ownedIds.contains(e.id));
  if (additionalFilter != null) {
    eligible = eligible.where(additionalFilter);
  }
  final items = eligible.toList();

  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Item'),
      content: SizedBox(
        width: double.maxFinite,
        child: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(Spacing.lg),
                child: Text('No eligible items available.'),
              )
            : ListView(
                shrinkWrap: true,
                children: items
                    .map((e) => ListTile(
                          dense: true,
                          title: Text(e.name, style: const TextStyle(fontSize: 14)),
                          subtitle: Text(_categoryLabel(e.category), style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            addItem(ref, rangerId, e.id);
                          },
                        ))
                    .toList(),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
