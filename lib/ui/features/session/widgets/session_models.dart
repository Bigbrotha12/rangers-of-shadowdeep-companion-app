import 'package:flutter/material.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_utils.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

// ── Data Classes ──

class StatRow {
  final int move;
  final int fight;
  final int shoot;
  final int armour;
  final int will;
  final int health;
  final int? damage;

  const StatRow({
    required this.move,
    required this.fight,
    required this.shoot,
    required this.armour,
    required this.will,
    required this.health,
    this.damage,
  });
}

class NamedAbility {
  final String key;
  final String name;
  final String description;
  final int? abilityId; // DB RangerAbility.id for per-copy tracking
  const NamedAbility({required this.key, required this.name, required this.description, this.abilityId});
}

class NamedSkill {
  final String key;
  final String name;
  final int value;
  const NamedSkill({required this.key, required this.name, required this.value});
}

// ── Helpers ──

Map<String, int> computeEquipMods(List<RangerEquipmentWithName> items) {
  return computeEquipmentModifiers(items);
}

// ── Stat Table Widget ──

class StatTable extends StatelessWidget {
  const StatTable({required this.stats, super.key});

  final StatRow stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const cellWidth = 30.0;
    final labels = <String>['M', 'F', 'S', 'A', 'W', 'H'];
    final values = <int>[stats.move, stats.fight, stats.shoot, stats.armour, stats.will, stats.health];
    if (stats.damage != null) {
      labels.add('D');
      values.add(stats.damage!);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: labels.map((l) => SizedBox(
            width: cellWidth,
            child: Text(l, textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              )),
          )).toList(),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < values.length; i++)
              SizedBox(
                width: cellWidth,
                child: Text('${values[i]}', textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stats.damage != null && i >= 6
                        ? theme.colorScheme.tertiary
                        : null,
                  )),
              ),
          ],
        ),
      ],
    );
  }
}
