import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../domain/constants/heroic_abilities.dart';
import '../../../../domain/constants/spells.dart';
import '../../../../domain/constants/skills.dart';
import '../../../../domain/constants/companion_types.dart' show companionTypeKeyFromId;
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/ranger_repository_provider.dart';
import '../../../core/widgets/stat_display.dart';
import '../../../core/widgets/placeholder_image.dart';
import '../view_models/ranger_detail_provider.dart';

class RangerDetailView extends ConsumerWidget {
  const RangerDetailView({
    required this.rangerId,
    super.key,
  });

  final int rangerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rangerAsync = ref.watch(rangerDetailProvider(rangerId));

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
                      context.push('/rangers/$rangerId/companions');
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
                      _StatsTab(ranger: ranger),
                      _AbilitiesTab(ranger: ranger),
                      _SkillsTab(ranger: ranger),
                      _EquipmentTab(ranger: ranger),
                      _CompanionsTab(rangerId: rangerId),
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
                ref.invalidate(rangerDetailProvider(rangerId));
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
                ref.invalidate(rangerDetailProvider(rangerId));
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
  const _StatsTab({required this.ranger});

  final RangerDetail ranger;

  @override
  Widget build(BuildContext context) {
    final r = ranger.ranger;

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
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              StatDisplay(label: 'Move', baseValue: r.move),
              StatDisplay(label: 'Fight', baseValue: r.fight),
              StatDisplay(label: 'Shoot', baseValue: r.shoot),
              StatDisplay(label: 'Armour', baseValue: r.armour),
              StatDisplay(label: 'Will', baseValue: r.will),
              StatDisplay(
                label: 'Health',
                baseValue: r.health,
                effectiveValue: r.currentHealth,
              ),
            ],
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

class _EquipmentTab extends StatelessWidget {
  const _EquipmentTab({required this.ranger});

  final RangerDetail ranger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ranger.equipment.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Equipment',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No starting equipment selected.',
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
      itemCount: ranger.equipment.length,
      itemBuilder: (context, index) {
        final item = ranger.equipment[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: PlaceholderImage(
              assetPath: _getItemAssetPath(item.category),
              category: _getItemCategory(item.category),
              width: 40,
              height: 40,
            ),
            title: Text(item.name),
            subtitle: item.equipment.currentUses != null
                ? Text('Uses: ${item.equipment.currentUses}')
                : null,
          ),
        );
      },
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
                  onPressed: () => context.push('/rangers/$rangerId/companions'),
                  icon: const Icon(Icons.pets),
                  label: const Text('View Companion Types'),
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
                    onPressed: () => context.push('/rangers/$rangerId/companions'),
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: PlaceholderImage(
                        assetPath: 'assets/images/companions/${companionTypeKeyFromId(companion.companionTypeId)}.png',
                        category: 'companion',
                        width: 40,
                        height: 40,
                      ),
                      title: Text(companion.customName),
                      subtitle: Text(
                        'PP: ${companion.progressionPoints}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onTap: () {
                        // TODO: Navigate to companion detail when companion detail view is wired to DB
                      },
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
