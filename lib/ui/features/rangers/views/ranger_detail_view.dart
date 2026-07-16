import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../domain/constants/heroic_abilities.dart';
import '../../../../domain/constants/spells.dart';
import '../../../../domain/constants/skills.dart';
import '../../../../domain/constants/companion_types.dart' show companionTypeKeyFromId, getCompanionType;
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/ranger_repository_provider.dart';
import '../../../core/widgets/stat_display.dart';
import '../../../core/widgets/placeholder_image.dart';
import '../view_models/ranger_detail_provider.dart';
import '../view_models/rangers_provider.dart';

class RangerDetailView extends ConsumerStatefulWidget {
  const RangerDetailView({
    required this.rangerId,
    super.key,
  });

  final int rangerId;

  @override
  ConsumerState<RangerDetailView> createState() => _RangerDetailViewState();
}

class _RangerDetailViewState extends ConsumerState<RangerDetailView> {
  Map<String, int> _computeStatModifiers(RangerDetail ranger) {
    final stats = <String, int>{};
    const effectMappings = {
      'damage_modifier': 'damage',
      'armour_bonus': 'armour',
      'fight_bonus': 'fight',
      'fight_penalty': 'fight',
      'shoot_bonus': 'shoot',
      'will_bonus': 'will',
      'will_penalty': 'will',
      'move_bonus': 'move',
      'move_penalty': 'move',
    };

    for (final item in ranger.equipment) {
      if (item.slotIndex == null) continue;
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

  Future<void> _equipItem(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    final ranger = await ref.read(rangerDetailProvider(widget.rangerId).future);
    if (ranger == null) return;
    final usedSlots = ranger.equipment
      .where((e) => e.slotIndex != null)
      .map((e) => e.slotIndex!)
      .toSet();
    for (int i = 0; i < 6; i++) {
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
      currentUses: equipment?.hasUses == true ? Value(equipment!.maxUses) : const Value(null),
    ));
    ref.invalidate(rangerDetailProvider(widget.rangerId));
  }

  @override
  Widget build(BuildContext context) {
    final rangerAsync = ref.watch(rangerDetailProvider(widget.rangerId));

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Ranger')),
            body: const Center(child: Text('Ranger not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(ranger.ranger.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      _showRenameDialog(context, ref, ranger);
                      break;
                    case 'companions':
                      context.push('/rangers/${widget.rangerId}/companions');
                      break;
                    case 'delete':
                      _showDeleteDialog(context, ref, ranger);
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
                    value: 'companions',
                    child: ListTile(
                      leading: Icon(Icons.pets),
                      title: Text('View Companions'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
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
                _RangerHeader(ranger: ranger),
                const TabBar(
                  isScrollable: true,
                  labelPadding: EdgeInsets.only(left: 8, right: 16),
                  tabs: [
                    Tab(text: 'Stats'),
                    Tab(text: 'Abilities'),
                    Tab(text: 'Skills'),
                    Tab(text: 'Equipment'),
                    Tab(text: 'Companions'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _StatsTab(
                        ranger: ranger,
                        statModifiers: _computeStatModifiers(ranger),
                      ),
                      _AbilitiesTab(ranger: ranger),
                      _SkillsTab(ranger: ranger),
                      _EquipmentTab(
                        ranger: ranger,
                        onEquip: _equipItem,
                        onUnequip: _unequipItem,
                        onRemove: _removeItem,
                        onAdd: _addItem,
                      ),
                      _CompanionsTab(rangerId: widget.rangerId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Ranger')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Ranger')),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, RangerDetail ranger) {
    final controller = TextEditingController(text: ranger.ranger.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Ranger'),
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
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              
              final repo = ref.read(rangerRepositoryProvider);
              await repo.updateRanger(RangersCompanion(
                id: Value(ranger.ranger.id),
                name: Value(newName),
                updatedAt: Value(DateTime.now()),
              ));
              
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(rangerDetailProvider(widget.rangerId));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, RangerDetail ranger) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ranger'),
        content: Text('Delete ${ranger.ranger.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(rangerRepositoryProvider);
              await repo.deleteRanger(ranger.ranger.id);
              
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(rangerDetailProvider(widget.rangerId));
                ref.invalidate(rangersListProvider);
                context.go('/rangers');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _RangerHeader extends StatelessWidget {
  const _RangerHeader({required this.ranger});

  final RangerDetail ranger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ranger.ranger;

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          PlaceholderImage(
            assetPath: 'assets/images/rangers/default_ranger.png',
            category: 'ranger',
            width: 64,
            height: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level ${r.level} | XP: ${r.experiencePoints}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'RP: ${r.baseRecruitmentPoints} | HP: ${r.currentHealth}/${r.health}',
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

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.ranger, required this.statModifiers});

  final RangerDetail ranger;
  final Map<String, int> statModifiers;

  @override
  Widget build(BuildContext context) {
    final r = ranger.ranger;

    int effective(String key, int base) {
      final mod = statModifiers[key];
      return mod != null ? base + mod : base;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                StatDisplay(label: 'Move', baseValue: r.move, effectiveValue: effective('move', r.move)),
                StatDisplay(label: 'Fight', baseValue: r.fight, effectiveValue: effective('fight', r.fight)),
                StatDisplay(label: 'Shoot', baseValue: r.shoot, effectiveValue: effective('shoot', r.shoot)),
                StatDisplay(label: 'Armour', baseValue: r.armour, effectiveValue: effective('armour', r.armour)),
                StatDisplay(label: 'Will', baseValue: r.will, effectiveValue: effective('will', r.will)),
                StatDisplay(
                  label: 'Health',
                  baseValue: r.health,
                  effectiveValue: r.currentHealth,
                ),
                StatDisplay(
                  label: 'Damage',
                  baseValue: statModifiers['damage'] ?? 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recruitment Points',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${r.baseRecruitmentPoints}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'RP',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          if (r.notes.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              r.notes,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _AbilitiesTab extends StatelessWidget {
  const _AbilitiesTab({required this.ranger});

  final RangerDetail ranger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ranger.heroicAbilities.isEmpty && ranger.spells.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Abilities',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No heroic abilities or spells selected.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ranger.heroicAbilities.isNotEmpty) ...[
            Text(
              'Heroic Abilities',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...ranger.heroicAbilities.map((ability) {
              final data = heroicAbilities.firstWhere(
                (a) => a.key == ability.abilityKey,
                orElse: () => heroicAbilities.first,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(data.name),
                  subtitle: Text(
                    data.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          if (ranger.spells.isNotEmpty) ...[
            Text(
              'Spells',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...ranger.spells.map((spell) {
              final data = spells.firstWhere(
                (s) => s.key == spell.abilityKey,
                orElse: () => spells.first,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.tertiary,
                  ),
                  title: Text(data.name),
                  subtitle: Text(
                    data.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _SkillsTab extends StatelessWidget {
  const _SkillsTab({required this.ranger});

  final RangerDetail ranger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ranger.skillBonuses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Skill Bonuses',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No skill bonuses assigned during creation.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ranger.skillBonuses.length,
      itemBuilder: (context, index) {
        final skillBonus = ranger.skillBonuses[index];
        final skill = skills.firstWhere(
          (s) => s.key == skillBonus.skillKey,
          orElse: () => skills.first,
        );

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
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '+${skillBonus.value}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EquipmentTab extends ConsumerWidget {
  const _EquipmentTab({
    required this.ranger,
    required this.onEquip,
    required this.onUnequip,
    required this.onRemove,
    required this.onAdd,
  });

  final RangerDetail ranger;
  final Future<void> Function(RangerEquipmentData item) onEquip;
  final Future<void> Function(RangerEquipmentData item) onUnequip;
  final Future<void> Function(int itemId) onRemove;
  final Future<void> Function(int equipmentId) onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final equipped = List<RangerEquipmentWithName?>.generate(6, (i) {
      try {
        return ranger.equipment.firstWhere((e) => e.slotIndex == i);
      } catch (_) {
        return null;
      }
    });
    final inventory = ranger.equipment.where((e) => e.slotIndex == null).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Equipment Slots ──────────────────────────────────
        Text('Equipment (${equipped.where((e) => e != null).length}/6 Slots)',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(6, (i) {
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
              title: Text(item?.name ?? 'Empty Slot', style: TextStyle(
                fontWeight: item != null ? FontWeight.bold : null,
                color: item != null ? null : theme.colorScheme.onSurfaceVariant,
              )),
              subtitle: item?.equipment.currentUses != null
                  ? Text('Uses: ${item!.equipment.currentUses}')
                  : null,
              trailing: item != null
                  ? IconButton(
                      icon: const Icon(Icons.indeterminate_check_box, size: 20),
                      onPressed: () => onUnequip(item.equipment),
                      tooltip: 'Unequip',
                    )
                  : null,
            ),
          );
        }),

        const SizedBox(height: 16),

        // ── Inventory ─────────────────────────────────────────
        Row(
          children: [
            Text('Inventory (${inventory.length})',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddItemDialog(context, ref),
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
              leading: PlaceholderImage(
                assetPath: _getItemAssetPath(item.category),
                category: _getItemCategory(item.category),
                width: 32,
                height: 32,
              ),
              title: Text(item.name, style: const TextStyle(fontSize: 14)),
              subtitle: item.equipment.currentUses != null
                  ? Text('Uses: ${item.equipment.currentUses}', style: const TextStyle(fontSize: 12))
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (equipped.where((e) => e != null).length < 6)
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: () => onEquip(item.equipment),
                      tooltip: 'Equip',
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => onRemove(item.equipment.id),
                    tooltip: 'Remove',
                  ),
                ],
              ),
            ),
          )),
      ],
    );
  }

  Future<void> _showAddItemDialog(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(rangerRepositoryProvider);
    final allEquipment = await repo.getAllEquipment();
    final ownedIds = ranger.equipment.map((e) => e.equipment.equipmentId).toSet();

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
                  onAdd(e.id);
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
}

class _CompanionsTab extends ConsumerWidget {
  const _CompanionsTab({required this.rangerId});

  final int rangerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rangerAsync = ref.watch(rangerDetailProvider(rangerId));

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) {
          return const Center(child: Text('Ranger not found'));
        }

        if (ranger.companions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Companions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recruit companions to join your company.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/rangers/$rangerId/companions/recruit?brp=${ranger.ranger.baseRecruitmentPoints}'),
                  icon: const Icon(Icons.pets),
                  label: const Text('Recruit Companions'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ranger.companions.length} Companion(s)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push('/rangers/$rangerId/companions/recruit?brp=${ranger.ranger.baseRecruitmentPoints}'),
                    icon: const Icon(Icons.add),
                    label: const Text('Recruit'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ranger.companions.length,
                itemBuilder: (context, index) {
                  final companion = ranger.companions[index];
                  final typeKey = companionTypeKeyFromId(companion.companionTypeId);
                  final type = getCompanionType(typeKey);
                  final customSkills = Map<String, int>.from(
                    const JsonDecoder().convert(companion.customSkills) as Map? ?? {},
                  );
                  int effectiveStat(int base, String key) =>
                      base + (customSkills[key] ?? 0);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => context.push('/rangers/$rangerId/companions/${companion.id}'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            PlaceholderImage(
                              assetPath: 'assets/images/companions/$typeKey.png',
                              category: 'companion',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    companion.customName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'PP: ${companion.progressionPoints}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (type != null)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: ['M', 'F', 'S', 'A', 'W', 'H'].map((l) =>
                                      SizedBox(
                                        width: 24,
                                        child: Text(
                                          l,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ).toList(),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      effectiveStat(type.move, 'move'),
                                      effectiveStat(type.fight, 'fight'),
                                      effectiveStat(type.shoot, 'shoot'),
                                      effectiveStat(type.armour, 'armour'),
                                      effectiveStat(type.will, 'will'),
                                      effectiveStat(type.health, 'health'),
                                    ].map((v) =>
                                      SizedBox(
                                        width: 24,
                                        child: Text(
                                          '$v',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ).toList(),
                                  ),
                                ],
                              ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
