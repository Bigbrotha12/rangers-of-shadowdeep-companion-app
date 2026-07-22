import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/spells.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';
import 'package:rangers_mobile/domain/services/stat_calculation_service.dart' hide computeEquipmentModifiers;
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_utils.dart';
import 'package:rangers_mobile/ui/core/widgets/hp_delta_control.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';
import 'package:rangers_mobile/ui/features/session/widgets/session_models.dart';
import 'package:rangers_mobile/ui/features/session/widgets/status_effect_sheet.dart';

class PartyMemberCard extends ConsumerStatefulWidget {
  const PartyMemberCard({required this.member, required this.rangerId, super.key});

  final PartyMemberState member;
  final int rangerId;

  @override
  ConsumerState<PartyMemberCard> createState() => _PartyMemberCardState();
}

class _PartyMemberCardState extends ConsumerState<PartyMemberCard> {
  bool _isExpanded = false;

  Future<void> _toggleItemActive(RangerEquipmentData item) async {
    await toggleItemActive(ref, item, widget.rangerId);
  }

  Future<void> _confirmAndUseItem(BuildContext context, RangerEquipmentData item, String itemName) async {
    final remaining = item.currentUses ?? 0;
    final confirmed = await showUseItemChargeDialog(context, itemName, remaining);
    if (confirmed) {
      await useItemCharge(ref, item.id, widget.rangerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = widget.member;
    final rangerAsync = ref.watch(rangerDetailProvider(widget.rangerId));

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) return const SizedBox.shrink();

        // ── Equipment filtered for this member ──
        final memberEquip = ranger.equipment
          .where((e) => e.slotIndex != null)
          .where((e) => member.type == 'ranger'
            ? e.equipment.equippedBy == 'ranger'
            : e.equipment.companionId == member.id)
          .toList();

        // ── Stats computation ──
        final equipMods = computeEquipMods(memberEquip);
        StatRow stats;

        // Compute combined penalties from both permanent injuries (parsed from notes)
        // and active status effects
        final rangerInjuryKeys = (ranger.ranger.notes.contains('[Injury]'))
            ? RegExp(r'\[Injury\]\s*(\w+(?:_\w+)*)')
                .allMatches(ranger.ranger.notes)
                .map((m) => m.group(1)!)
                .toList()
            : <String>[];

        if (member.type == 'ranger') {
          final seMove = computeStatPenalty('move',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          final seFight = computeStatPenalty('fight',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          final seShoot = computeStatPenalty('shoot',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          final seWill = computeStatPenalty('will',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          final seHealth = computeStatPenalty('health',
            permanentInjuryKeys: rangerInjuryKeys,
            statusEffectKeys: member.statusEffects,
          );
          stats = StatRow(
            move: ranger.ranger.move + seMove + (equipMods['move'] ?? 0),
            fight: ranger.ranger.fight + seFight + (equipMods['fight'] ?? 0),
            shoot: ranger.ranger.shoot + seShoot + (equipMods['shoot'] ?? 0),
            armour: ranger.ranger.armour + (equipMods['armour'] ?? 0),
            will: ranger.ranger.will + seWill + (equipMods['will'] ?? 0),
            health: member.maxHealth + seHealth,
            damage: equipMods['damage'],
          );
        } else {
          final companion = ranger.companions.where((c) => c.id == member.id).firstOrNull;
          if (companion != null) {
            final typeKey = companionTypeKeyFromId(companion.companionTypeId);
            final type = getCompanionType(typeKey);
            final customSkills = ranger.companionCustomSkills[companion.id] ?? <String, int>{};
            final injuries = ranger.companionInjuryKeys[companion.id] ?? <String>[];
            final statusEffectPenaltyMove = computeStatPenalty('move',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );
            final statusEffectPenaltyFight = computeStatPenalty('fight',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );
            final statusEffectPenaltyShoot = computeStatPenalty('shoot',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );
            final statusEffectPenaltyWill = computeStatPenalty('will',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );
            final statusEffectPenaltyHealth = computeStatPenalty('health',
              permanentInjuryKeys: injuries,
              statusEffectKeys: member.statusEffects,
            );

            stats = StatRow(
              move: (type?.move ?? 6) + (customSkills['move'] ?? 0) + statusEffectPenaltyMove + (equipMods['move'] ?? 0),
              fight: (type?.fight ?? 0) + (customSkills['fight'] ?? 0) + statusEffectPenaltyFight + (equipMods['fight'] ?? 0),
              shoot: (type?.shoot ?? 0) + (customSkills['shoot'] ?? 0) + statusEffectPenaltyShoot + (equipMods['shoot'] ?? 0),
              armour: (type?.armour ?? 10) + (equipMods['armour'] ?? 0),
              will: (type?.will ?? 0) + (customSkills['will'] ?? 0) + statusEffectPenaltyWill + (equipMods['will'] ?? 0),
              health: (type?.health ?? 10) + statusEffectPenaltyHealth + companion.bonusHealth,
              damage: equipMods['damage'],
            );
          } else {
            stats = StatRow(
              move: 6, fight: 0, shoot: 0, armour: 10, will: 0, health: member.maxHealth,
            );
          }
        }

        // ── Abilities, spells, and skills for expanded view ──
        List<NamedAbility> memberHeroicAbilities = [];
        List<NamedAbility> memberSpells = [];
        List<NamedSkill> memberSkills = [];

        if (member.type == 'ranger') {
          memberHeroicAbilities = ranger.heroicAbilities.map((a) {
            final data = heroicAbilities.firstWhere(
              (h) => h.key == a.abilityKey,
              orElse: () => heroicAbilities.first,
            );
            return NamedAbility(key: a.abilityKey, name: data.name, description: data.description);
          }).toList();

          memberSpells = ranger.spells.map((s) {
            final data = spells.firstWhere(
              (sp) => sp.key == s.abilityKey,
              orElse: () => spells.first,
            );
            return NamedAbility(key: s.abilityKey, name: data.name, description: data.description, abilityId: s.id);
          }).toList();

          memberSkills = ranger.skillBonuses
            .where((s) => s.value > 0)
            .map((s) {
              final skill = skills.firstWhere(
                (sk) => sk.key == s.skillKey,
                orElse: () => skills.first,
              );
              return NamedSkill(key: s.skillKey, name: skill.name, value: s.value);
            }).toList();
        } else {
          final companion = ranger.companions.where((c) => c.id == member.id).firstOrNull;
          if (companion != null) {
            final typeKey = companionTypeKeyFromId(companion.companionTypeId);
            final type = getCompanionType(typeKey);

            final heroicKeys = ranger.companionHeroicAbilityKeys[companion.id] ?? [];
            final spellAbilities = ranger.companionSpellAbilities[companion.id] ?? [];

            memberHeroicAbilities = heroicKeys.map((key) {
              final data = heroicAbilities.firstWhere(
                (h) => h.key == key,
                orElse: () => heroicAbilities.first,
              );
              return NamedAbility(key: key, name: data.name, description: data.description);
            }).toList();

            memberSpells = spellAbilities.map((a) {
              final data = spells.firstWhere(
                (sp) => sp.key == a.abilityKey,
                orElse: () => spells.first,
              );
              return NamedAbility(
                key: a.abilityKey,
                name: data.name,
                description: data.description,
                abilityId: a.id,
              );
            }).toList();

            final companionSkillValues = <String, int>{};
            if (type != null) companionSkillValues.addAll(type.baseSkills);
            final customSkills = ranger.companionCustomSkills[companion.id] ?? <String, int>{};
            for (final e in customSkills.entries) {
              companionSkillValues[e.key] = (companionSkillValues[e.key] ?? 0) + e.value;
            }

            memberSkills = companionSkillValues.entries
              .where((e) => e.value > 0)
              .map((e) {
                final skill = skills.firstWhere(
                  (sk) => sk.key == e.key,
                  orElse: () => skills.first,
                );
                return NamedSkill(key: e.key, name: skill.name, value: e.value);
              }).toList();
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: member.isDead
              ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
              : member.hasActed
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: member.isDead ? null : () => setState(() => _isExpanded = !_isExpanded),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wideEnough = constraints.maxWidth >= 480;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ──
                      Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            backgroundColor: member.isDead
                                ? theme.colorScheme.error
                                : member.type == 'ranger'
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.secondaryContainer,
                            child: Icon(
                              member.isDead ? Icons.close : member.type == 'ranger' ? Icons.person : Icons.pets,
                              color: member.isDead
                                  ? theme.colorScheme.onError
                                  : member.type == 'ranger'
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name and HP
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: member.isDead ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                Text(
                                  'HP: ${member.currentHealth}/${member.maxHealth}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: member.currentHealth <= 0
                                        ? theme.colorScheme.error
                                        : member.currentHealth <= member.maxHealth ~/ 3
                                            ? statusOrange(theme)
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Treasure indicator (visible in collapsed state)
                          if (member.carryingTreasure) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.diamond, color: statusAmber(theme), size: 20),
                            const SizedBox(width: 4),
                          ],

                          // Undo death
                          if (member.isDead)
                            TextButton.icon(
                              icon: const Icon(Icons.restore, size: 18),
                              label: const Text('Restore'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => ref.read(activeSessionProvider.notifier).updatePartyHealth(member.id, member.type, member.maxHealth),
                            ),

                          // Stats table (inline in header when wide enough)
                          if (wideEnough && !member.isDead) ...[
                            const SizedBox(width: 8),
                            StatTable(stats: stats),
                            const SizedBox(width: 8),
                          ],

                          // HP Controls
                          if (!member.isDead) ...[
                            HpDeltaControl(
                              delta: 1,
                              onDecrement: (d) => ref.read(activeSessionProvider.notifier).updatePartyHealth(member.id, member.type, -d),
                              onIncrement: (d) => ref.read(activeSessionProvider.notifier).updatePartyHealth(member.id, member.type, d),
                            ),
                            IconButton(
                              icon: AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.expand_more),
                              ),
                              onPressed: () => setState(() => _isExpanded = !_isExpanded),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'DEAD',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // ── Stats row (always visible, below header on narrow screens) ──
                      if (!member.isDead) ...[
                        if (!wideEnough) ...[
                          const SizedBox(height: 12),
                          StatTable(stats: stats),
                        ],
                      ],

                      // ── Round Status (only when expanded) ──
                      if (_isExpanded && !member.isDead) ...[
                        const SizedBox(height: 12),
                        Text('Round Status', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  member.hasActed ? Icons.check_circle : Icons.check_circle_outline,
                                  color: member.hasActed ? statusGreen(theme) : theme.colorScheme.onSurfaceVariant,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    member.hasActed ? 'Activated this turn' : 'Not yet activated',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: member.hasActed
                                      ? null
                                      : () => ref.read(activeSessionProvider.notifier)
                                          .markPartyActed(member.id, member.type),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.secondary,
                                  ),
                                  child: Text(member.hasActed ? 'Done' : 'Activate'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.diamond,
                                  color: member.carryingTreasure
                                      ? statusAmber(theme)
                                      : member.isAnimal
                                          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    member.isAnimal
                                        ? 'Animals cannot carry treasure'
                                        : (member.carryingTreasure ? 'Carrying a treasure' : 'Not carrying treasure'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (member.isAnimal)
                                  const SizedBox.shrink()
                                else
                                  TextButton(
                                    onPressed: () => ref.read(activeSessionProvider.notifier)
                                        .toggleCarryingTreasure(member.id, member.type),
                                    style: TextButton.styleFrom(
                                      foregroundColor: theme.colorScheme.secondary,
                                    ),
                                    child: Text(member.carryingTreasure ? 'Remove' : 'Carry'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ── Status Effects (only when expanded) ──
                      if (_isExpanded && !member.isDead) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Status Effects', style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            )),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Manage'),
                              onPressed: () => _showStatusEffectSheet(context, member),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildStatusEffectsSection(context, member, ranger),
                      ],

                      // ── Heroic Abilities (only when expanded) ──
                      if (_isExpanded && !member.isDead && memberHeroicAbilities.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Heroic Abilities', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        ...memberHeroicAbilities.map((ability) {
                          final isUsed = member.usedAbilities[ability.key] ?? false;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.push('/reference/heroic_abilities/${ability.key}'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            ability.name,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            ability.description,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: isUsed,
                                      onChanged: (_) => ref.read(activeSessionProvider.notifier).toggleAbilityUsed(member.id, member.type, ability.key),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],

                      // ── Spells (only when expanded) ──
                      if (_isExpanded && !member.isDead && memberSpells.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Spells', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        ...memberSpells.asMap().entries.map((entry) {
                          final spell = entry.value;
                          final index = entry.key;
                          // Use DB abilityId for ranger spells, list index for companion spells
                          final uniqueKey = spell.abilityId != null
                              ? 'spell:${spell.abilityId}'
                              : 'spell:${member.id}:$index:${spell.key}';
                          final isUsed = member.usedAbilities[uniqueKey] ?? false;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.push('/reference/spells/${spell.key}'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.tertiary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            spell.name,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            spell.description,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: isUsed,
                                      onChanged: (_) => ref.read(activeSessionProvider.notifier).toggleAbilityUsed(
                                        member.id,
                                        member.type,
                                        uniqueKey,
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],

                      // ── Skills (only when expanded) ──
                      if (_isExpanded && !member.isDead && memberSkills.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Skills', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: memberSkills.map((skill) {
                            return ActionChip(
                              label: Text('${skill.name} +${skill.value}'),
                              onPressed: () => context.push('/reference/skills/${skill.key}'),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            );
                          }).toList(),
                        ),
                      ],

                      // ── Equipment rows (only when expanded) ──
                      if (_isExpanded && !member.isDead && memberEquip.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Equipment', style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(height: 4),
                        ...memberEquip.map((item) {
                          final hasUses = item.equipment.currentUses != null && item.equipment.currentUses! > 0;
                          final effects = Map<String, dynamic>.from(
                            const JsonDecoder().convert(item.effects) as Map,
                          );
                          final damageMod = effects['damage_modifier'] as int?;
                          final armourMod = effects['armour_bonus'] as int?;
                          final label = StringBuffer(item.name);
                          if (damageMod != null) label.write(' ${damageMod >= 0 ? '+' : ''}$damageMod');
                          if (armourMod != null) label.write(' ${armourMod >= 0 ? '+' : ''}$armourMod');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          label.toString(),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (hasUses)
                                          Text(
                                            'Uses: ${item.equipment.currentUses}',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (hasUses)
                                    TextButton.icon(
                                      icon: Icon(Icons.remove_circle_outline, size: 22, color: theme.colorScheme.error),
                                      label: Text('Use', style: TextStyle(fontSize: 15, color: theme.colorScheme.error)),
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
                                    onChanged: (_) => _toggleItemActive(item.equipment),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusEffectsSection(BuildContext context, PartyMemberState member, RangerDetail ranger) {
    final displayInjuries = member.type == 'ranger'
        ? ((ranger.ranger.notes.contains('[Injury]'))
            ? RegExp(r'\[Injury\]\s*(\w+(?:_\w+)*)')
                .allMatches(ranger.ranger.notes)
                .map((m) => m.group(1)!)
                .toList()
            : <String>[])
        : (ranger.companionInjuryKeys[member.id] ?? <String>[]);

    if (member.statusEffects.isEmpty && displayInjuries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('No status effects', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        ...member.statusEffects.map((key) => _buildEffectChip(context, key, isInjury: false)),
        ...displayInjuries.map((key) => _buildEffectChip(context, key, isInjury: true)),
      ],
    );
  }

  Widget _buildEffectChip(BuildContext context, String key, {required bool isInjury}) {
    final theme = Theme.of(context);
    final effect = getStatusEffect(key);
    final injury = permanentInjuries.where((i) => i.key == key).firstOrNull;
    final name = effect?.name ?? injury?.name ?? key.replaceAll('_', ' ');

    Color chipColor;
    if (isInjury) {
      chipColor = theme.colorScheme.error;
    } else if (effect?.category == StatusEffectCategory.positive) {
      chipColor = statusGreen(theme);
    } else {
      chipColor = theme.colorScheme.error;
    }

    return InputChip(
      label: Text(name, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary)),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      deleteIcon: Icon(Icons.close, size: 14, color: theme.colorScheme.onPrimary.withValues(alpha: 0.7)),
      onDeleted: () => ref.read(activeSessionProvider.notifier)
          .removeStatusEffectFromMember(widget.member.id, widget.member.type, key),
      onPressed: () => context.push(
        isInjury
            ? '/reference/permanent_injuries/$key'
            : '/reference/status_effects/$key',
      ),
    );
  }

  Future<void> _showStatusEffectSheet(BuildContext context, PartyMemberState member) async {
    final currentEffects = List<String>.from(member.statusEffects);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      builder: (ctx) => StatusEffectSheet(activeEffects: currentEffects),
    );
    if (result != null) {
      ref.read(activeSessionProvider.notifier)
          .updateMemberStatusEffects(widget.member.id, widget.member.type, result.toList());
    }
  }
}

// ── Party Panel ──

class PartyPanel extends StatelessWidget {
  const PartyPanel({required this.session, super.key});

  final ActiveSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Party',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (session.party.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No party members',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...session.party.map((member) => PartyMemberCard(
            member: member,
            rangerId: session.rangerId,
          )),
      ],
    );
  }
}
