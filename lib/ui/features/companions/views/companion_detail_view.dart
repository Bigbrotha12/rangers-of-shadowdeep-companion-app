import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../data/database/app_database.dart' hide CompanionType;
import '../../../../data/repositories/ranger_repository_provider.dart';
import '../../../../data/repositories/companion_repository_provider.dart';
import '../../../../domain/constants/basic_equipment.dart';
import '../../../../domain/constants/companion_types.dart';
import '../../../../domain/constants/skills.dart';
import '../../../core/widgets/stat_display.dart';
import '../../../core/widgets/placeholder_image.dart';
import '../view_models/companion_provider.dart';
import '../../rangers/view_models/ranger_detail_provider.dart';

class CompanionDetailView extends ConsumerWidget {
  const CompanionDetailView({
    required this.rangerId,
    required this.companionId,
    super.key,
  });

  final int rangerId;
  final int companionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companion = ref.watch(companionProvider(companionId));

    if (companion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Companion')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final type = companion.type;
    if (type == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Companion')),
        body: const Center(child: Text('Unknown companion type')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(companion.customName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  _showRenameDialog(context, ref, companion);
                  break;
                case 'assign_skill':
                  context.push('/rangers/$rangerId/companions/$companionId/assign-skill');
                  break;
                case 'progression':
                  context.push('/rangers/$rangerId/companions/$companionId/progression');
                  break;
                case 'remove':
                  _showRemoveDialog(context, ref, companion);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Rename'),
                ),
              ),
              const PopupMenuItem(
                value: 'assign_skill',
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Assign +3 Skill Bonus'),
                ),
              ),
              const PopupMenuItem(
                value: 'progression',
                child: ListTile(
                  leading: Icon(Icons.trending_up),
                  title: Text('View Progression'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  title: Text('Remove', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            _CompanionHeader(companion: companion, type: type),
            const TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.only(left: 8, right: 16),
              tabs: [
                Tab(text: 'Stats'),
                Tab(text: 'Skills'),
                Tab(text: 'Injuries'),
                Tab(text: 'Info'),
                Tab(text: 'Equipment'),
              ],
            ),
            Expanded(
              child:               TabBarView(
                children: [
                  _StatsTab(
                    companion: companion,
                    type: type,
                    rangerId: rangerId,
                    companionId: companionId,
                  ),
                  _SkillsTab(companion: companion, type: type),
                  _InjuriesTab(companion: companion),
                  _InfoTab(companion: companion, type: type),
                  _CompanionEquipmentTab(
                    rangerId: rangerId,
                    companionId: companionId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, CompanionData companion) {
    final controller = TextEditingController(text: companion.customName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Companion'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(companionProvider(companion.id).notifier)
                  .updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, WidgetRef ref, CompanionData companion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Companion'),
        content: Text('Remove ${companion.customName} from your company?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(companionRepositoryProvider);
              await repo.deleteCompanion(companion.id);
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(rangerDetailProvider);
                context.pop();
              }
            },
            child: Text('Remove', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _CompanionHeader extends StatelessWidget {
  const _CompanionHeader({
    required this.companion,
    required this.type,
  });

  final CompanionData companion;
  final CompanionType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          PlaceholderImage(
            assetPath: 'assets/images/companions/${type.key}.png',
            category: 'companion',
            width: 64,
            height: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companion.customName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  type.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'RP: ${type.rpCost} | PP: ${companion.progressionPoints}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab({
    required this.companion,
    required this.type,
    required this.rangerId,
    required this.companionId,
  });

  final CompanionData companion;
  final CompanionType type;
  final int rangerId;
  final int companionId;

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab> {
  Future<void> _toggleItemActive(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    await repo.updateRangerEquipment(RangerEquipmentCompanion(
      id: Value(item.id),
      isActive: Value(!item.isActive),
    ));
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Map<String, int> _computeStatModifiers(List<RangerEquipmentWithName> items) {
    final stats = <String, int>{};
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

    for (final item in items) {
      if (!item.isActive) continue;
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
      } catch (_) {}
    }
    return stats;
  }

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
        ? _computeStatModifiers(companionEquipment)
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
                  onPressed: () => _toggleItemActive(item.equipment),
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

class _SkillsTab extends StatelessWidget {
  const _SkillsTab({
    required this.companion,
    required this.type,
  });

  final CompanionData companion;
  final CompanionType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get all skills with their values
    final skillValues = <String, int>{};
    for (final skill in skills) {
      final baseValue = type.baseSkills[skill.key] ?? 0;
      final customValue = companion.customSkills[skill.key] ?? 0;
      skillValues[skill.key] = baseValue + customValue;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final value = skillValues[skill.key] ?? 0;

        return ListTile(
          title: Text(skill.name),
          subtitle: Text(
            skill.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: value > 0
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value > 0 ? '+$value' : '+0',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: value > 0
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InjuriesTab extends StatelessWidget {
  const _InjuriesTab({required this.companion});

  final CompanionData companion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (companion.permanentInjuries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Injuries',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This companion has no permanent injuries.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: companion.permanentInjuries.length,
      itemBuilder: (context, index) {
        final injury = companion.permanentInjuries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.warning_amber,
              color: theme.colorScheme.error,
            ),
            title: Text(injury.replaceAll('_', ' ').toUpperCase()),
            subtitle: const Text('Permanent injury'),
          ),
        );
      },
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.companion,
    required this.type,
  });

  final CompanionData companion;
  final CompanionType type;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSection(
            title: 'Description',
            content: type.description,
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Equipment',
            content: type.notes,
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Special Rules',
            content: type.specialRules ?? 'None',
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Recruitment Cost',
            content: '${type.rpCost} RP',
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CompanionEquipmentTab extends ConsumerStatefulWidget {
  const _CompanionEquipmentTab({
    required this.rangerId,
    required this.companionId,
  });

  final int rangerId;
  final int companionId;

  @override
  ConsumerState<_CompanionEquipmentTab> createState() => _CompanionEquipmentTabState();
}

class _CompanionEquipmentTabState extends ConsumerState<_CompanionEquipmentTab> {
  Future<void> _equipItem(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    final ranger = await ref.read(rangerDetailProvider(widget.rangerId).future);
    if (ranger == null) return;
    final equipped = ranger.equipment
      .where((e) => e.slotIndex != null)
      .where((e) => e.equipment.equippedBy == widget.companionId.toString())
      .toList();
    final usedSlots = equipped.map((e) => e.slotIndex!).toSet();
    for (int i = 0; i < maxCompanionEquipmentSlots; i++) {
      if (!usedSlots.contains(i)) {
        await repo.updateRangerEquipment(RangerEquipmentCompanion(
          id: Value(item.id),
          slotIndex: Value(i),
        ));
        ref.invalidate(rangerDetailProvider(widget.rangerId));
        return;
      }
    }
  }

  Future<void> _unequipItem(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    await repo.updateRangerEquipment(RangerEquipmentCompanion(
      id: Value(item.id),
      slotIndex: const Value(null),
    ));
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _removeItem(int itemId) async {
    final repo = ref.read(rangerRepositoryProvider);
    await repo.deleteRangerEquipment(itemId);
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _addItem(int equipmentId) async {
    final repo = ref.read(rangerRepositoryProvider);
    final equipment = await repo.getEquipmentById(equipmentId);
    await repo.insertRangerEquipment(RangerEquipmentCompanion.insert(
      rangerId: widget.rangerId,
      equipmentId: equipmentId,
      equippedBy: Value(widget.companionId.toString()),
      currentUses: equipment?.hasUses == true ? Value(equipment!.maxUses) : const Value(null),
    ));
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _toggleActive(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    await repo.updateRangerEquipment(RangerEquipmentCompanion(
      id: Value(item.id),
      isActive: Value(!item.isActive),
    ));
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _useItem(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    await repo.useEquipmentCharge(item.id);
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  Future<void> _confirmAndUseItem(BuildContext context, RangerEquipmentData item, String itemName) async {
    final remaining = item.currentUses ?? 0;
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
    if (confirmed == true) {
      await _useItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangerAsync = ref.watch(rangerDetailProvider(widget.rangerId));

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) {
          return const Center(child: Text('Ranger not found'));
        }

        final companionItems = ranger.equipment
          .where((e) => e.equipment.equippedBy == widget.companionId.toString())
          .toList();

        final equipped = List<RangerEquipmentWithName?>.generate(
          maxCompanionEquipmentSlots,
          (i) {
            try {
              return companionItems.firstWhere((e) => e.slotIndex == i);
            } catch (_) {
              return null;
            }
          },
        );
        final inventory = companionItems.where((e) => e.slotIndex == null).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Equipment Slots ──
            Text('Equipment (${equipped.where((e) => e != null).length}/$maxCompanionEquipmentSlots Slots)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(maxCompanionEquipmentSlots, (i) {
              final item = equipped[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
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
                            if (item.equipment.currentUses != null && item.equipment.currentUses! > 0)
                              TextButton.icon(
                                icon: const Icon(Icons.remove_circle_outline, size: 24, color: Colors.red),
                                label: const Text('Use', style: TextStyle(fontSize: 17, color: Colors.red)),
                                onPressed: () => _confirmAndUseItem(context, item.equipment, item.name),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Switch(
                              value: item.isActive,
                              onChanged: (_) => _toggleActive(item.equipment),
                            ),
                            IconButton(
                              icon: const Icon(Icons.indeterminate_check_box, size: 20),
                              onPressed: () => _unequipItem(item.equipment),
                              tooltip: 'Unequip',
                            ),
                          ],
                        )
                      : null,
                ),
              );
            }),

            const SizedBox(height: 16),

            // ── Inventory ──
            Row(
              children: [
                Text('Inventory (${inventory.length})',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddItemDialog(context),
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
              ...inventory.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.inventory_2, size: 20, color: theme.colorScheme.onSurfaceVariant),
                  title: Text(item.name, style: const TextStyle(fontSize: 14)),
                  subtitle: item.equipment.currentUses != null
                      ? Text('Uses: ${item.equipment.currentUses}', style: const TextStyle(fontSize: 12))
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.equipment.currentUses != null && item.equipment.currentUses! > 0)
                        TextButton.icon(
                          icon: const Icon(Icons.remove_circle_outline, size: 24, color: Colors.red),
                          label: const Text('Use', style: TextStyle(fontSize: 17, color: Colors.red)),
                          onPressed: () => _confirmAndUseItem(context, item.equipment, item.name),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (equipped.where((e) => e != null).length < maxCompanionEquipmentSlots)
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: () => _equipItem(item.equipment),
                          tooltip: 'Equip',
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _removeItem(item.equipment.id),
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                ),
              )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final repo = ref.read(rangerRepositoryProvider);
    final allEquipment = await repo.getAllEquipment();
    final ranger = await ref.read(rangerDetailProvider(widget.rangerId).future);
    if (ranger == null) return;
    final ownedIds = ranger.equipment
      .where((e) => e.equipment.equippedBy == widget.companionId.toString())
      .map((e) => e.equipment.equipmentId)
      .toSet();

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Item'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: allEquipment
              .where((e) => !ownedIds.contains(e.id))
              .map((e) => ListTile(
                dense: true,
                title: Text(e.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(e.category, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _addItem(e.id);
                },
              ))
              .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
