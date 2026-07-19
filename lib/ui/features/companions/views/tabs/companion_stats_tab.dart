import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/ui/core/widgets/stat_display.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_utils.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';

class CompanionStatsTab extends ConsumerStatefulWidget {
  const CompanionStatsTab({
    required this.companion,
    required this.type,
    required this.rangerId,
    required this.companionId,
    super.key,
  });

  final CompanionData companion;
  final CompanionTypeDefinition type;
  final int rangerId;
  final int companionId;

  @override
  ConsumerState<CompanionStatsTab> createState() => CompanionStatsTabState();
}

class CompanionStatsTabState extends ConsumerState<CompanionStatsTab> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangerAsync = ref.watch(rangerDetailProvider(widget.rangerId));

    final companionEquipment = rangerAsync.whenOrNull(
      data: (ranger) {
        if (ranger == null) return <RangerEquipmentWithName>[];
        return ranger.equipment
          .where((e) => e.slotIndex != null)
          .where((e) => e.equipment.equippedBy == widget.companionId.toString())
          .toList();
      },
    );

    final statModifiers = companionEquipment != null
        ? computeEquipmentModifiers(companionEquipment)
        : <String, int>{};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Base Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                StatDisplay(label: 'Move', baseValue: widget.type.move),
                StatDisplay(label: 'Fight', baseValue: widget.type.fight),
                StatDisplay(label: 'Shoot', baseValue: widget.type.shoot),
                StatDisplay(label: 'Armour', baseValue: widget.type.armour),
                StatDisplay(label: 'Will', baseValue: widget.type.will),
                StatDisplay(label: 'Health', baseValue: widget.type.health),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Effective Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                StatDisplay(
                  label: 'Move',
                  baseValue: widget.type.move,
                  effectiveValue: widget.companion.effectiveMove + (statModifiers['move'] ?? 0),
                ),
                StatDisplay(
                  label: 'Fight',
                  baseValue: widget.type.fight,
                  effectiveValue: widget.companion.effectiveFight + (statModifiers['fight'] ?? 0),
                ),
                StatDisplay(
                  label: 'Shoot',
                  baseValue: widget.type.shoot,
                  effectiveValue: widget.companion.effectiveShoot + (statModifiers['shoot'] ?? 0),
                ),
                StatDisplay(
                  label: 'Armour',
                  baseValue: widget.type.armour,
                  effectiveValue: widget.companion.effectiveArmour + (statModifiers['armour'] ?? 0),
                ),
                StatDisplay(
                  label: 'Will',
                  baseValue: widget.type.will,
                  effectiveValue: widget.companion.effectiveWill + (statModifiers['will'] ?? 0),
                ),
                StatDisplay(
                  label: 'Health',
                  baseValue: widget.type.health,
                  effectiveValue: widget.companion.effectiveHealth,
                ),
                if (statModifiers.containsKey('damage'))
                  StatDisplay(
                    label: 'Damage',
                    baseValue: 0,
                    effectiveValue: statModifiers['damage']!,
                  ),
              ],
            ),
          ),
          if (companionEquipment != null && companionEquipment.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Equipment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: companionEquipment.map((item) {
                final effects = Map<String, dynamic>.from(
                  const JsonDecoder().convert(item.effects) as Map,
                );
                final damageMod = effects['damage_modifier'] as int?;
                final armourMod = effects['armour_bonus'] as int?;
                final label = StringBuffer(item.name);
                if (damageMod != null) {
                  label.write(' ${damageMod >= 0 ? '+' : ''}$damageMod');
                }
                if (armourMod != null) {
                  label.write(' ${armourMod >= 0 ? '+' : ''}$armourMod');
                }

                return ActionChip(
                  avatar: Icon(
                    item.isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 14,
                    color: item.isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  label: Text(label.toString(), style: theme.textTheme.labelSmall),
                  onPressed: () => toggleItemActive(ref, item.equipment, widget.rangerId),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
