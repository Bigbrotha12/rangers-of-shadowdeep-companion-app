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
import '../../../../domain/constants/magic_items.dart';
import '../../../../domain/constants/heroic_abilities.dart';
import '../../../../domain/constants/spells.dart';
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
        length: 6,
        child: Column(
          children: [
            _CompanionHeader(companion: companion, type: type),
            const TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.only(left: 8, right: 16),
              tabs: [
                Tab(text: 'Stats'),
                Tab(text: 'Skills'),
                Tab(text: 'Abilities'),
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
                  _AbilitiesTab(
                    companion: companion,
                    type: type,
                    rangerId: rangerId,
                  ),
                  _InjuriesTab(companion: companion),
                  _InfoTab(companion: companion, type: type),
                  type.isAnimal
                      ? const _AnimalEquipmentDisabled()
                      : _CompanionEquipmentTab(
                          rangerId: rangerId,
                          companionId: companionId,
                          type: type,
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

    // Get skills with values > 0
    final skillEntries = skills.map((skill) {
      final baseValue = type.baseSkills[skill.key] ?? 0;
      final customValue = companion.customSkills[skill.key] ?? 0;
      return (skill: skill, value: baseValue + customValue);
    }).where((e) => e.value > 0).toList();

    if (skillEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No skills',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This companion has no skills yet.',
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
      itemCount: skillEntries.length,
      itemBuilder: (context, index) {
        final entry = skillEntries[index];
        final skill = entry.skill;
        final value = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
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
                '+$value',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            onTap: () => context.push(
              '/reference/skills/${skill.key}',
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

class _AbilitiesTab extends ConsumerWidget {
  const _AbilitiesTab({
    required this.companion,
    required this.type,
    required this.rangerId,
  });

  final CompanionData companion;
  final CompanionType type;
  final int rangerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isConjuror = type.key == 'conjuror';
    final maxSpells = isConjuror ? 3 : null;

    final hasHeroic = companion.heroicAbilityKeys.isNotEmpty;
    final hasSpells = isConjuror;
    final hasSkillBonuses = companion.customSkills.isNotEmpty;

    if (!hasHeroic && !hasSpells && !hasSkillBonuses) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No abilities',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Earn abilities through progression rewards.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
          // ── Heroic Abilities ──
          if (hasHeroic) ...[
            Text(
              'Heroic Abilities',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...companion.heroicAbilityKeys.map((key) {
              final data = heroicAbilities.firstWhere(
                (a) => a.key == key,
                orElse: () => heroicAbilities.first,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Icon(Icons.star, color: theme.colorScheme.primary),
                  title: Text(data.name),
                  subtitle: Text(
                    data.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => context.push(
                    '/reference/heroic_abilities/$key',
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          if (isConjuror) ...[
            // ── Spells ──
            Text(
              'Spells',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (companion.spellKeys.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No spells selected.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...companion.spellKeys.map((key) {
                final data = spells.firstWhere(
                  (s) => s.key == key,
                  orElse: () => spells.first,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: Icon(Icons.auto_awesome, color: theme.colorScheme.tertiary),
                    title: Text(data.name),
                    subtitle: Text(
                      data.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () => context.push(
                            '/reference/spells/$key',
                          ),
                          tooltip: 'View details',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            size: 20,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            ref.read(companionProvider(companion.id).notifier)
                                .removeSpellKey(key);
                          },
                          tooltip: 'Remove spell',
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
            if (companion.spellKeys.length < maxSpells!)
              OutlinedButton.icon(
                onPressed: () => _showSpellPicker(context, ref, isConjuror),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Select Spell (${companion.spellKeys.length}/$maxSpells)',
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Conjuror can select up to $maxSpells spell${maxSpells == 1 ? '' : 's'}.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Skills from customSkills ──
          if (hasSkillBonuses) ...[
            Text(
              'Skill Bonuses',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: companion.customSkills.entries.map((entry) {
                final skill = skills.firstWhere(
                  (s) => s.key == entry.key,
                  orElse: () => skills.first,
                );
                return ActionChip(
                  avatar: const Icon(Icons.school, size: 14),
                  label: Text(
                    '${skill.name} +${entry.value}',
                    style: theme.textTheme.labelSmall,
                  ),
                  onPressed: () => context.push(
                    '/reference/skills/${entry.key}',
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showSpellPicker(BuildContext context, WidgetRef ref, bool isConjuror) {
    final existing = [...companion.spellKeys];
    final selected = Set<String>.from(existing);
    final max = isConjuror ? 3 : 999;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isConjuror
              ? 'Select Spells (max $max)'
              : 'Select Spells'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: spells.length,
              itemBuilder: (ctx, i) {
                final spell = spells[i];
                final isSelected = selected.contains(spell.key);
                final atMax = selected.length >= max && !isSelected;

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: atMax
                      ? null
                      : (checked) {
                          setState(() {
                            if (checked == true) {
                              selected.add(spell.key);
                            } else {
                              selected.remove(spell.key);
                            }
                          });
                        },
                  title: Text(spell.name),
                  subtitle: Text(
                    spell.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(companionProvider(companion.id).notifier)
                    .setSpellKeys(selected.toList());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalEquipmentDisabled extends StatelessWidget {
  const _AnimalEquipmentDisabled();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Animals cannot carry treasure or items.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CompanionEquipmentTab extends ConsumerStatefulWidget {
  const _CompanionEquipmentTab({
    required this.rangerId,
    required this.companionId,
    required this.type,
  });

  final int rangerId;
  final int companionId;
  final CompanionType type;

  @override
  ConsumerState<_CompanionEquipmentTab> createState() => _CompanionEquipmentTabState();
}

class _CompanionEquipmentTabState extends ConsumerState<_CompanionEquipmentTab> {
  /// Safely reads a non-nullable Drift column that may contain null at runtime
  String _safeDbKey(EquipmentData e) {
    try {
      return e.itemKey;
    } catch (_) {
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
      .where((e) => e.equipment.equippedBy == widget.companionId.toString())
      .toList();
    final usedSlots = companionEquipped.map((e) => e.slotIndex!).toSet();

    // Auto-replace: unequip mundane versions replaced by magic items
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
          equippedBy: Value(widget.companionId.toString()),
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
      equippedBy: const Value('pool'),
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
      equippedBy: const Value('pool'),
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
    final type = widget.type;

    final standardWeaponKeys = type.allowedWeaponTypes;
    final standardArmourKeys = type.allowedArmourTypes;

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) {
          return const Center(child: Text('Ranger not found'));
        }

        final companionItems = ranger.equipment
          .where((e) => e.equipment.equippedBy == widget.companionId.toString() || e.equipment.equippedBy == 'pool')
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

        // Determine which standard items are replaced by a magic equipped item
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
            // ── Standard Equipment (always carried, no slot cost) ──
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

            // ── Additional Equipment Slots ──
            Text('Additional Slots (${equipped.where((e) => e != null).length}/$maxCompanionEquipmentSlots)',
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
              ...inventory.map((item) {
                final canEquip = _canCompanionEquip(item.itemKey, item.category) 
                  && equipped.where((e) => e != null).length < maxCompanionEquipmentSlots;
                return Card(
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
                        if (canEquip)
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

  Future<void> _showAddItemDialog(BuildContext context) async {
    final repo = ref.read(rangerRepositoryProvider);
    final allEquipment = await repo.getAllEquipment();
    final ranger = await ref.read(rangerDetailProvider(widget.rangerId).future);
    if (ranger == null) return;
    final ownedIds = ranger.equipment
      .map((e) => e.equipment.equipmentId)
      .toSet();

    // Safely resolve itemKey from EquipmentData (Drift may have null for non-nullable columns)
    String safeItemKey(EquipmentData e) {
      try {
        return e.itemKey;
      } catch (_) {
        return '';
      }
    }

    final eligible = allEquipment
      .where((e) => !ownedIds.contains(e.id))
      .where((e) => _canCompanionEquip(safeItemKey(e), e.category))
      .toList();

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Item'),
        content: SizedBox(
          width: double.maxFinite,
          child: eligible.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No eligible items available.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : ListView(
                shrinkWrap: true,
                children: eligible
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
