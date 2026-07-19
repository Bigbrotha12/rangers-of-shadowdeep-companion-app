import 'package:flutter/material.dart';
import 'package:rangers_mobile/domain/constants/base_stats.dart';
import 'package:rangers_mobile/domain/constants/basic_equipment.dart';
import 'package:rangers_mobile/domain/constants/companion_progression.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/herbs_potions.dart';
import 'package:rangers_mobile/domain/constants/magic_items.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/domain/constants/spells.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';
import 'package:rangers_mobile/domain/constants/treasure_table.dart';

class ReferenceEntry {
  final String id;
  final String title;
  final String category;
  final String description;
  final String? detailedDescription;
  final Map<String, String> metadata;

  const ReferenceEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.detailedDescription,
    this.metadata = const {},
  });
}

class ReferenceCategory {
  final String key;
  final String label;
  final IconData icon;
  final String description;

  const ReferenceCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.description,
  });
}

class QuickReferenceEntry {
  final String id;
  final String title;
  final String content;
  final IconData icon;

  const QuickReferenceEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
  });
}

final List<ReferenceCategory> referenceCategories = [
  const ReferenceCategory(
    key: 'heroic_abilities',
    label: 'Heroic Abilities',
    icon: Icons.flash_on,
    description: '16 special combat manoeuvres and survival tricks',
  ),
  const ReferenceCategory(
    key: 'spells',
    label: 'Spells',
    icon: Icons.auto_awesome,
    description: '10 arcane powers for rangers and conjurors',
  ),
  const ReferenceCategory(
    key: 'skills',
    label: 'Skills',
    icon: Icons.track_changes,
    description: '15 skills for scouting, combat, and survival',
  ),
  const ReferenceCategory(
    key: 'companions',
    label: 'Companions',
    icon: Icons.groups,
    description: '14 companion types with stat lines',
  ),
  const ReferenceCategory(
    key: 'basic_equipment',
    label: 'Basic Equipment',
    icon: Icons.backpack,
    description: '12 basic items from the king\'s armouries',
  ),
  const ReferenceCategory(
    key: 'magic_items',
    label: 'Magic Items',
    icon: Icons.star,
    description: 'Enchanted weapons, armour, and wondrous items',
  ),
  const ReferenceCategory(
    key: 'herbs_potions',
    label: 'Herbs & Potions',
    icon: Icons.medication,
    description: '20 herbs and potions with temporary effects',
  ),
  const ReferenceCategory(
    key: 'permanent_injuries',
    label: 'Permanent Injuries',
    icon: Icons.healing,
    description: '8 injuries with cumulative stat penalties',
  ),
  const ReferenceCategory(
    key: 'treasure_tables',
    label: 'Treasure Tables',
    icon: Icons.monetization_on,
    description: 'Treasure, herbs, weapons, and magic item tables',
  ),
  const ReferenceCategory(
    key: 'status_effects',
    label: 'Status Effects',
    icon: Icons.science,
    description: 'Poison, disease, hunger, exhaustion, and other temporary conditions',
  ),
];

final List<QuickReferenceEntry> quickReferenceEntries = [
  const QuickReferenceEntry(
    id: 'combat_modifiers',
    title: 'Combat Modifiers',
    icon: Icons.shield,
    content: '''RESOLVING COMBAT
1. Both figures roll a die.
2. Add Fight Stat + bonuses → Combat Score.
3. Higher score wins the fight.
4. Winner applies damage modifier.
5. Subtract opponent's Armour from total.
6. Apply any damage multipliers.
7. Remaining total = damage to loser's Health.
8. Winner chooses: stay, push 1", or step back 1".

MULTIPLE COMBAT
Each figure gains +2 per allied figure also in combat
with the opponent (unless that ally is also in combat).
If both sides would get bonuses, cancel them out
(only one side gains the net bonus).

CRITICAL HITS
Natural 20 = auto win +5 damage.
Evil creatures never score critical hits.

DAMAGE MODIFIERS
Two-handed weapon: +2
Dagger: -1
Staff: -1 (and opponent also -1)''',
  ),
  const QuickReferenceEntry(
    id: 'shooting_modifiers',
    title: 'Shooting Modifiers',
    icon: Icons.ads_click,
    content: '''RESOLVING SHOOTING
1. Both figures roll a die.
2. Shooter adds Shoot Stat, target adds Fight Stat.
3. Shooter must have higher score to hit.
4. Damage resolved same as hand-to-hand combat.

SHOOTING MODIFIERS (add to target's Combat Score)
+1 Intervening Terrain (per piece)
+2 Light Cover (rocks, walls, thick wood up to ½ body)
+4 Heavy Cover (solid cover almost completely hiding body)
+1 Hurried Shot (shooter already moved this activation)
-2 Large Target (over 8' tall or unusually broad)''',
  ),
  const QuickReferenceEntry(
    id: 'swimming_modifiers',
    title: 'Swimming Modifiers',
    icon: Icons.water,
    content: '''SWIMMING
When activating in deep water, make a Swim Roll (TN5).
Failure: lose all actions + take damage = amount failed by.
Deep water = rough ground for movement.
Fighting in deep water: -2 Fight.

SWIMMING MODIFIERS
Light Armour: -2
Heavy Armour: -5
Shield: -1
Carrying Treasure: -2''',
  ),
  const QuickReferenceEntry(
    id: 'movement_rules',
    title: 'Movement Rules',
    icon: Icons.directions_walk,
    content: '''BASIC MOVEMENT
First move: full Move stat in inches.
Second move: half Move stat in inches.

OBSTRUCTIONS (climbing)
Distance climbed counts double for movement.
Figures may end movement partway up a terrain piece.

ROUGH GROUND
Distance moved costs double (mud, bog, scree, shallow water).

JUMPING
Max horizontal jump: half Move +1".
Make Acrobatics Roll (TN = 1 + inches jumped).
+5 TN if jump begins or ends in rough ground.
Failure: jump half distance + fall, activation ends.

FALLING
3" or less: no damage.
More than 3": damage = inches fallen × 1.5 (round down).
Damage bypasses Armour.
Voluntary fall counts as move action.
Fall >3": make Acrobatics Roll (TN10) or activation ends.''',
  ),
  const QuickReferenceEntry(
    id: 'creature_ai',
    title: 'Evil Creature AI',
    icon: Icons.pest_control,
    content: '''CREATURE ACTIVATION FLOWCHART
During Creature Phase, activate creatures in order
of highest current Health (ties: random choice).

⬇

STEP 1: Is the creature in combat?
YES → Fight. If it wins, stay in combat.
        No second action.
NO  → Go to Step 2.

⬇

STEP 2: Is there a hero in line of sight?
YES → If has missile weapon & in range:
        Shoot closest hero.
        Second action: reload (crossbow) or nothing.
      If no missile weapon:
        Move toward closest hero.
        Second action: fight (if in combat) or move closer.
NO  → Go to Step 3.

⬇

STEP 3: Does scenario include a Target Point?
YES → Move toward Target Point (1 action).
        Return to Step 2 for second action.
NO  → Move in random direction (1 action).
        Return to Step 2 for second action.''',
  ),
];

class RulesReferenceService {
  List<ReferenceEntry> _allEntries = [];
  bool _initialized = false;

  List<ReferenceEntry> get allEntries {
    _ensureInitialized();
    return _allEntries;
  }

  List<ReferenceEntry> getEntriesByCategory(String category) {
    _ensureInitialized();
    return _allEntries.where((e) => e.category == category).toList();
  }

  ReferenceEntry? getEntryById(String category, String id) {
    _ensureInitialized();
    for (final entry in _allEntries) {
      if (entry.category == category && entry.id == id) return entry;
    }
    return null;
  }

  List<ReferenceEntry> search(String query) {
    _ensureInitialized();
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    return _allEntries.where((entry) {
      return entry.title.toLowerCase().contains(lower) ||
          entry.description.toLowerCase().contains(lower) ||
          (entry.detailedDescription?.toLowerCase().contains(lower) ?? false) ||
          entry.metadata.values.any((v) => v.toLowerCase().contains(lower));
    }).toList();
  }

  int categoryCount(String category) {
    _ensureInitialized();
    return _allEntries.where((e) => e.category == category).length;
  }

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _allEntries = _buildAllEntries();
  }

  List<ReferenceEntry> _buildAllEntries() {
    final entries = <ReferenceEntry>[];

    for (final ability in heroicAbilities) {
      entries.add(ReferenceEntry(
        id: ability.key,
        title: ability.name,
        category: 'heroic_abilities',
        description: ability.description,
        metadata: {'when_to_use': ability.whenToUse},
      ));
    }

    for (final spell in spells) {
      entries.add(ReferenceEntry(
        id: spell.key,
        title: spell.name,
        category: 'spells',
        description: spell.description,
        metadata: {
          'target_type': spell.targetType,
          if (spell.willRollTn != null) 'will_roll_tn': '${spell.willRollTn}',
        },
      ));
    }

    for (final skill in skills) {
      entries.add(ReferenceEntry(
        id: skill.key,
        title: skill.name,
        category: 'skills',
        description: skill.description,
      ));
    }

    for (final companion in companionTypes) {
      entries.add(ReferenceEntry(
        id: companion.key,
        title: companion.name,
        category: 'companions',
        description: companion.description,
        detailedDescription: companion.specialRules,
        metadata: {
          'rp_cost': '${companion.rpCost}',
          'move': '${companion.move}',
          'fight': '${companion.fight}',
          'shoot': '${companion.shoot}',
          'armour': '${companion.armour}',
          'will': '${companion.will}',
          'health': '${companion.health}',
          'notes': companion.notes,
          'is_animal': '${companion.isAnimal}',
          if (companion.baseSkills.isNotEmpty)
            'base_skills': companion.baseSkills.entries
                .map((e) => '${e.key.replaceAll('_', ' ')} +${e.value}')
                .join(', '),
        },
      ));
    }

    for (final item in basicEquipmentList) {
      entries.add(ReferenceEntry(
        id: item.key,
        title: item.name,
        category: 'basic_equipment',
        description: item.description,
        metadata: {
          'category_type': item.category,
          'effects': item.effects,
          if (item.isTwoHanded) 'two_handed': 'true',
          if (item.isLight) 'light': 'true',
        },
      ));
    }

    for (final item in magicItemsList) {
      entries.add(ReferenceEntry(
        id: item.key,
        title: item.name,
        category: 'magic_items',
        description: item.description,
        metadata: {
          'category_type': item.category,
          'effects': item.effects,
          if (item.maxUses != null) 'max_uses': '${item.maxUses}',
        },
      ));
    }

    for (final herb in herbsAndPotions) {
      entries.add(ReferenceEntry(
        id: herb.key,
        title: herb.name,
        category: 'herbs_potions',
        description: herb.description,
        metadata: {'effects': herb.effects},
      ));
    }

    for (final injury in permanentInjuries) {
      entries.add(ReferenceEntry(
        id: injury.key,
        title: injury.name,
        category: 'permanent_injuries',
        description: injury.description,
        metadata: {
          'effect': injury.effect,
          if (injury.affectedStat != null) 'affected_stat': injury.affectedStat!,
          'max_times': '${injury.maxTimesReceived}',
        },
      ));
    }

    for (final effect in statusEffects) {
      entries.add(ReferenceEntry(
        id: effect.key,
        title: effect.name,
        category: 'status_effects',
        description: effect.description,
        metadata: {
          'is_temporary': '${effect.isTemporary}',
          'category': effect.category.name,
          if (effect.statModifiers.isNotEmpty)
            'stat_modifiers': effect.statModifiers.entries
                .map((e) => '${e.key} ${e.value >= 0 ? '+' : ''}${e.value}')
                .join(', '),
          if (effect.specialRule != null) 'special_rule': effect.specialRule!,
        },
      ));
    }

    _addTreasureTableEntries(entries);
    _addQuickReferenceEntries(entries);

    return entries;
  }

  void _addTreasureTableEntries(List<ReferenceEntry> entries) {
    entries.add(ReferenceEntry(
      id: 'main_treasure_table',
      title: 'Treasure Table (d20)',
      category: 'treasure_tables',
      description: 'Roll on the Treasure Table for each secured treasure token.',
      metadata: {
        'table_data': treasureTable
            .map((e) => '${e.minRoll}-${e.maxRoll}: ${e.name}')
            .join('\n'),
      },
    ));
    entries.add(ReferenceEntry(
      id: 'herbs_potions_table',
      title: 'Herbs & Potions Table (d20)',
      category: 'treasure_tables',
      description: 'Roll on this sub-table when the Treasure Table result is "Herb or Potion".',
      metadata: {
        'table_data': herbsPotionsTable
            .map((e) => '${e.minRoll}-${e.maxRoll}: ${e.name}')
            .join('\n'),
      },
    ));
    entries.add(ReferenceEntry(
      id: 'weapons_armour_table',
      title: 'Weapons & Armour Table (d20)',
      category: 'treasure_tables',
      description: 'Roll on this sub-table when the Treasure Table result is "Weapon or Armour".',
      metadata: {
        'table_data': weaponsArmourTable
            .map((e) => '${e.minRoll}-${e.maxRoll}: ${e.name}')
            .join('\n'),
      },
    ));
    entries.add(ReferenceEntry(
      id: 'magic_items_table',
      title: 'Magic Items Table (d20)',
      category: 'treasure_tables',
      description: 'Roll on this sub-table when the Treasure Table result is "Magic Item".',
      metadata: {
        'table_data': magicItemsTable
            .map((e) => '${e.minRoll}-${e.maxRoll}: ${e.name}')
            .join('\n'),
      },
    ));
    entries.add(const ReferenceEntry(
      id: 'gold_and_jewels',
      title: 'Gold and Jewels',
      category: 'treasure_tables',
      description: 'A stash of valuables. The ranger may choose either +10 XP or have one companion gain 1 Progression Point.',
    ));
    entries.add(const ReferenceEntry(
      id: 'survival_table',
      title: 'Survival Table',
      category: 'treasure_tables',
      description: 'Roll for each hero reduced to 0 Health or less during a scenario. Rangers may add +1 to the roll.',
      metadata: {
        'table_data': '1-2: Dead\n3-4: Permanent Injury\n5-6: Badly Wounded\n7-8: Close Call\n9+: Full Recovery',
      },
    ));
    entries.add(ReferenceEntry(
      id: 'experience_table',
      title: 'Experience & Level Costs',
      category: 'treasure_tables',
      description: 'Rangers start at level 0. XP costs increase with each level bracket.',
      metadata: {
        'table_data': levelCosts
            .map((e) => 'Levels ${e.minLevel}-${e.maxLevel}: ${e.xpCost} XP')
            .join('\n'),
      },
    ));
    entries.add(const ReferenceEntry(
      id: 'level_bonuses',
      title: 'Level Bonuses',
      category: 'treasure_tables',
      description: 'Each level grants a specific bonus type, repeating every 4 levels.',
      metadata: {
        'table_data': 'Levels 1,5,9,13,...: Improve Skills (+5 total, max +2 per skill)\n'
            'Levels 2,6,10,14,...: Improve Stats (+1 to one stat)\n'
            'Levels 3,7,11,15,...: Gain +10 Recruitment Points\n'
            'Levels 4,8,12,16,...: New Heroic Ability or Spell',
      },
    ));
    entries.add(ReferenceEntry(
      id: 'companion_progression',
      title: 'Companion Progression Rewards',
      category: 'treasure_tables',
      description: 'Companions earn 1 PP per scenario survived. Rewards at thresholds.',
      metadata: {
        'table_data': progressionRewards
            .map((e) => '${e.threshold} PP: ${e.description}')
            .join('\n'),
      },
    ));
    entries.add(ReferenceEntry(
      id: 'recruitment_points',
      title: 'Recruitment Points Calculation',
      category: 'treasure_tables',
      description: 'Total RP depends on player count and Leadership skill.',
      metadata: {
        'table_data': recruitmentCalculations
            .map((e) => '${e.playerCount} Player(s): ${e.formula}, max ${e.maxCompanions} companions')
            .join('\n'),
      },
    ));
    entries.add(const ReferenceEntry(
      id: 'permanent_injury_table',
      title: 'Permanent Injury Table (d20)',
      category: 'treasure_tables',
      description: 'Roll on this table when the Survival Table result is Permanent Injury.',
      metadata: {
        'table_data': '1-2: Lost Toes\n3-5: Smashed Leg\n6-10: Crushed Arm\n'
            '11-12: Lost Fingers\n13-14: Never Quite as Strong\n'
            '15-16: Psychological Scars\n17-18: Smashed Jaw\n19-20: Lost Eye',
      },
    ));
  }

  void _addQuickReferenceEntries(List<ReferenceEntry> entries) {
    for (final qr in quickReferenceEntries) {
      entries.add(ReferenceEntry(
        id: qr.id,
        title: qr.title,
        category: 'quick_reference',
        description: qr.content,
      ));
    }
  }
}
