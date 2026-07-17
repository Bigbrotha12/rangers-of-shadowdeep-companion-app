import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/rangers.dart';
import 'tables/ranger_abilities.dart';
import 'tables/ranger_skills.dart';
import 'tables/companion_types.dart';
import 'tables/ranger_companions.dart';
import 'tables/equipment.dart';
import 'tables/ranger_equipment.dart';
import 'tables/injuries.dart';
import 'tables/sessions.dart';
import 'tables/session_events.dart';
import '../../domain/constants/magic_items.dart';
import '../../domain/constants/herbs_potions.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Rangers,
    RangerAbilities,
    RangerSkills,
    CompanionTypes,
    RangerCompanions,
    Equipment,
    RangerEquipment,
    Injuries,
    Sessions,
    SessionEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCompanionTypes();
          await _seedEquipment();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(rangerCompanions, rangerCompanions.claimedProgressionRewards);
            await m.addColumn(rangerCompanions, rangerCompanions.hasUsedRecruitmentBonus);
            await m.addColumn(rangerCompanions, rangerCompanions.bonusHealth);
          }
          if (from < 3) {
            await m.addColumn(rangerEquipment, rangerEquipment.slotIndex);
          }
          if (from < 4) {
            await m.addColumn(rangerEquipment, rangerEquipment.isActive);
          }
          if (from < 5) {
            await _migrateEquipmentEffects();
          }
        },
      );

  // Seed companion types from the rulebook
  Future<void> _seedCompanionTypes() async {
    final companionData = [
      (typeKey: 'arcanist', name: 'Arcanist', rpCost: 15, move: 6, fight: 2, shoot: 0, armour: 10, will: 2, health: 10, notes: 'Hand Weapon, Ancient Lore +5, Read Runes +5', isAnimal: false, baseSkills: '{"ancient_lore":5,"read_runes":5}'),
      (typeKey: 'archer', name: 'Archer', rpCost: 20, move: 6, fight: 2, shoot: 2, armour: 11, will: 1, health: 10, notes: 'Bow OR Crossbow, Dagger, Light Armour, Quiver', isAnimal: false, baseSkills: '{}'),
      (typeKey: 'barbarian', name: 'Barbarian', rpCost: 35, move: 6, fight: 4, shoot: 0, armour: 11, will: 3, health: 14, notes: 'Hand Weapon, Shield, Strength +5', isAnimal: false, baseSkills: '{"strength":5}'),
      (typeKey: 'conjuror', name: 'Conjuror', rpCost: 20, move: 6, fight: 0, shoot: 0, armour: 10, will: 3, health: 12, notes: 'Staff OR Hand Weapon, 2 Spells, 3rd Spell (+10 RP)', isAnimal: false, baseSkills: '{}'),
      (typeKey: 'guardsman', name: 'Guardsman', rpCost: 20, move: 6, fight: 3, shoot: 0, armour: 11, will: 2, health: 12, notes: 'Two-Handed Weapon, Light Armour', isAnimal: false, baseSkills: '{}'),
      (typeKey: 'hound', name: 'Hound', rpCost: 5, move: 8, fight: 0, shoot: 0, armour: 10, will: -2, health: 6, notes: 'Animal, Cannot Carry Treasure or Items, Limited Skill Rolls', isAnimal: true, baseSkills: '{}'),
      (typeKey: 'warhound', name: 'Warhound', rpCost: 10, move: 8, fight: 1, shoot: 0, armour: 10, will: 2, health: 8, notes: 'Animal, Cannot Carry Treasure or Items, Limited Skill Rolls', isAnimal: true, baseSkills: '{}'),
      (typeKey: 'bloodhound', name: 'Bloodhound', rpCost: 10, move: 8, fight: 0, shoot: 0, armour: 10, will: -2, health: 6, notes: 'Animal, Cannot Carry Treasure or Items, Limited Skill Rolls, Tracking +5, Ranger Tracking Bonus', isAnimal: true, baseSkills: '{"track":5}'),
      (typeKey: 'knight', name: 'Knight', rpCost: 35, move: 5, fight: 4, shoot: 0, armour: 13, will: 2, health: 12, notes: 'Hand Weapon, Shield, Heavy Armour, Strength +4', isAnimal: false, baseSkills: '{"strength":4}'),
      (typeKey: 'man_at_arms', name: 'Man-at-Arms', rpCost: 20, move: 6, fight: 3, shoot: 0, armour: 12, will: 2, health: 12, notes: 'Hand Weapon, Shield, Light Armour', isAnimal: false, baseSkills: '{}'),
      (typeKey: 'raptor', name: 'Raptor', rpCost: 10, move: 9, fight: 0, shoot: 0, armour: 14, will: 3, health: 1, notes: 'Animal, Cannot Carry Treasure or Items, Limited Skill Rolls, Perception +4', isAnimal: true, baseSkills: '{"perception":4}'),
      (typeKey: 'recruit', name: 'Recruit', rpCost: 10, move: 6, fight: 2, shoot: 0, armour: 10, will: 0, health: 10, notes: 'Hand Weapon', isAnimal: false, baseSkills: '{}'),
      (typeKey: 'rogue', name: 'Rogue', rpCost: 20, move: 7, fight: 1, shoot: 1, armour: 10, will: 1, health: 10, notes: 'Dagger, Throwing Knife, Climb +2, Perception +2, Pick Lock +5, Traps +5, Stealth +5', isAnimal: false, baseSkills: '{"climb":2,"perception":2,"pick_lock":5,"traps":5,"stealth":5}'),
      (typeKey: 'savage', name: 'Savage', rpCost: 35, move: 6, fight: 4, shoot: 0, armour: 10, will: 3, health: 14, notes: 'Two-Handed Weapon, Strength +5', isAnimal: false, baseSkills: '{"strength":5}'),
      (typeKey: 'swordsman', name: 'Swordsman', rpCost: 25, move: 6, fight: 4, shoot: 0, armour: 11, will: 2, health: 12, notes: 'Hand Weapon, Dagger, Light Armour', isAnimal: false, baseSkills: '{}'),
      (typeKey: 'templar', name: 'Templar', rpCost: 35, move: 5, fight: 4, shoot: 0, armour: 12, will: 2, health: 12, notes: 'Two-Handed Weapon, Heavy Armour, Strength +4', isAnimal: false, baseSkills: '{"strength":4}'),
      (typeKey: 'tracker', name: 'Tracker', rpCost: 30, move: 7, fight: 2, shoot: 2, armour: 11, will: 2, health: 12, notes: 'Staff, Bow, Quiver, Light Armour, Tracking +5', isAnimal: false, baseSkills: '{"track":5}'),
    ];

    await batch((batch) {
      batch.insertAll(
        companionTypes,
        companionData.map((c) => CompanionTypesCompanion.insert(
              typeKey: c.typeKey,
              name: c.name,
              rpCost: c.rpCost,
              move: c.move,
              fight: c.fight,
              shoot: c.shoot,
              armour: c.armour,
              will: c.will,
              health: c.health,
              notes: Value(c.notes),
              isAnimal: Value(c.isAnimal),
              baseSkills: Value(c.baseSkills),
            )),
      );
    });
  }

  // Seed equipment from the rulebook
  Future<void> _seedEquipment() async {
    final equipmentData = [
      // Basic Equipment
      (itemKey: 'bow', name: 'Bow', category: 'basic_weapon', description: 'The favoured missile weapon of rangers, bows may be loaded and fired in a single action. Maximum range 24". No damage modifier. Requires quiver.', effects: '{"damage_modifier":0,"range":24,"reload":"single_action"}', hasUses: false, maxUses: null),
      (itemKey: 'crossbow', name: 'Crossbow', category: 'basic_weapon', description: 'Takes one action to load and one action to fire. +2 damage modifier, range 24". Requires quiver.', effects: '{"damage_modifier":2,"range":24,"reload":"load_and_fire"}', hasUses: false, maxUses: null),
      (itemKey: 'dagger', name: 'Dagger', category: 'basic_weapon', description: 'A knife not balanced for throwing. -1 damage modifier.', effects: '{"damage_modifier":-1}', hasUses: false, maxUses: null),
      (itemKey: 'hand_weapon', name: 'Hand Weapon', category: 'basic_weapon', description: 'Swords, clubs, axes, maces, spears. No modifiers in combat.', effects: '{"damage_modifier":0}', hasUses: false, maxUses: null),
      (itemKey: 'two_handed_weapon', name: 'Two-Handed Weapon', category: 'basic_weapon', description: 'Heavy melee weapons requiring two hands. +2 damage modifier.', effects: '{"damage_modifier":2}', hasUses: false, maxUses: null),
      (itemKey: 'throwing_knife', name: 'Throwing Knife', category: 'basic_weapon', description: 'Small throwing weapons. One shooting attack per knife per game, range 8", -1 damage. Can be used as backup melee weapon.', effects: '{"damage_modifier":-1,"range":8,"shots_per_game":1}', hasUses: false, maxUses: null),
      (itemKey: 'staff', name: 'Staff', category: 'basic_weapon', description: 'Defensive properties. -1 damage modifier, but opponent also gets -1 damage modifier in hand-to-hand.', effects: '{"damage_modifier":-1,"opponent_damage_modifier":-1}', hasUses: false, maxUses: null),
      (itemKey: 'shield', name: 'Shield', category: 'basic_gear', description: '+1 to Armour. Cannot carry two-handed weapon or staff.', effects: '{"armour_bonus":1}', hasUses: false, maxUses: null),
      (itemKey: 'quiver', name: 'Quiver', category: 'basic_gear', description: 'Required for bow/crossbow attacks. Can carry one piece of magic ammunition without taking an item slot.', effects: '{}', hasUses: false, maxUses: null),
      (itemKey: 'rope', name: 'Rope', category: 'basic_gear', description: 'At top of vertical structure, spend action to set rope. Any figure may use rope to climb without penalties.', effects: '{}', hasUses: false, maxUses: null),
      (itemKey: 'light_armour', name: 'Light Armour', category: 'basic_armour', description: 'Leather or nonmetal materials. +1 to Armour.', effects: '{"armour_bonus":1}', hasUses: false, maxUses: null),
      (itemKey: 'heavy_armour', name: 'Heavy Armour', category: 'basic_armour', description: 'Mostly metal construction. +2 to Armour, -1 to Move.', effects: '{"armour_bonus":2,"move_penalty":-1}', hasUses: false, maxUses: null),
      // Magic Weapons (sample)
      (itemKey: 'magic_hand_weapon', name: 'Hand Weapon, Magic', category: 'magic_weapon', description: 'Counts as magic and gives +1 Fight for rest of game when activated.', effects: '{"damage_modifier":0,"fight_bonus":1,"magic":true}', hasUses: true, maxUses: 5),
      (itemKey: 'magic_two_handed_weapon', name: 'Two-Handed Weapon, Magic', category: 'magic_weapon', description: 'Counts as magic and gives +1 Fight for rest of game when activated.', effects: '{"damage_modifier":2,"fight_bonus":1,"magic":true}', hasUses: true, maxUses: 5),
      (itemKey: 'magic_bow', name: 'Bow, Magic', category: 'magic_weapon', description: 'Counts as magic and gives +1 Fight for rest of game when activated.', effects: '{"damage_modifier":0,"range":24,"reload":"single_action","requires":"quiver","fight_bonus":1,"magic":true}', hasUses: true, maxUses: 5),
      (itemKey: 'magic_crossbow', name: 'Crossbow, Magic', category: 'magic_weapon', description: 'Counts as magic and gives +1 Fight for rest of game when activated.', effects: '{"damage_modifier":2,"range":24,"reload":"load_and_fire","requires":"quiver","fight_bonus":1,"magic":true}', hasUses: true, maxUses: 5),
      (itemKey: 'magic_staff', name: 'Staff, Magic', category: 'magic_weapon', description: 'Counts as magic and gives +1 Fight for rest of game when activated.', effects: '{"damage_modifier":-1,"opponent_damage_modifier":-1,"fight_bonus":1,"magic":true}', hasUses: true, maxUses: 5),
      (itemKey: 'light_hand_weapon', name: 'Hand Weapon, Light', category: 'magic_weapon', description: 'Does not take up an item slot.', effects: '{"damage_modifier":0,"light":true}', hasUses: false, maxUses: null),
      (itemKey: 'light_two_handed_weapon', name: 'Two-Handed Weapon, Light', category: 'magic_weapon', description: 'Does not take up an item slot.', effects: '{"damage_modifier":2,"light":true}', hasUses: false, maxUses: null),
      (itemKey: 'light_dagger', name: 'Dagger, Light', category: 'magic_weapon', description: 'Does not take up an item slot.', effects: '{"damage_modifier":-1,"light":true}', hasUses: false, maxUses: null),
      (itemKey: 'light_throwing_knife', name: 'Throwing Knife, Light', category: 'magic_weapon', description: 'Does not take up an item slot.', effects: '{"damage_modifier":-1,"range":8,"shots_per_game":1,"light":true}', hasUses: false, maxUses: null),
      (itemKey: 'brightness_shield', name: 'Shield, Brightness', category: 'magic_armour', description: 'Add +5 to Fight Roll when targeted by shooting attack.', effects: '{"armour_bonus":1,"brightness":true}', hasUses: true, maxUses: 5),
      (itemKey: 'brightness_light_armour', name: 'Light Armour, Brightness', category: 'magic_armour', description: 'Add +5 to Fight Roll when targeted by shooting attack.', effects: '{"armour_bonus":1,"brightness":true}', hasUses: true, maxUses: 5),
      (itemKey: 'brightness_heavy_armour', name: 'Heavy Armour, Brightness', category: 'magic_armour', description: 'Add +5 to Fight Roll when targeted by shooting attack.', effects: '{"armour_bonus":2,"move_penalty":-1,"brightness":true}', hasUses: true, maxUses: 5),
      (itemKey: 'elemental_strike_hand', name: 'Hand Weapon, Elemental Strike', category: 'magic_weapon', description: 'Additional 5 points of elemental magic damage when winning fight.', effects: '{"damage_modifier":0,"elemental_strike":5}', hasUses: true, maxUses: 3),
      (itemKey: 'elemental_strike_two_handed', name: 'Two-Handed Weapon, Elemental Strike', category: 'magic_weapon', description: 'Additional 5 points of elemental magic damage when winning fight.', effects: '{"damage_modifier":2,"elemental_strike":5}', hasUses: true, maxUses: 3),
      (itemKey: 'elemental_strike_staff', name: 'Staff, Elemental Strike', category: 'magic_weapon', description: 'Additional 5 points of elemental magic damage when winning fight.', effects: '{"damage_modifier":-1,"opponent_damage_modifier":-1,"elemental_strike":5}', hasUses: true, maxUses: 3),
      (itemKey: 'blocking_shield', name: 'Shield, Blocking', category: 'magic_armour', description: 'Block the blow when losing a fight. Take no damage.', effects: '{"armour_bonus":1,"blocking":true}', hasUses: true, maxUses: 1),
      (itemKey: 'blocking_light_armour', name: 'Light Armour, Blocking', category: 'magic_armour', description: 'Block the blow when losing a fight. Take no damage.', effects: '{"armour_bonus":1,"blocking":true}', hasUses: true, maxUses: 1),
      (itemKey: 'blocking_heavy_armour', name: 'Heavy Armour, Blocking', category: 'magic_armour', description: 'Block the blow when losing a fight. Take no damage.', effects: '{"armour_bonus":2,"move_penalty":-1,"blocking":true}', hasUses: true, maxUses: 1),
      (itemKey: 'blocking_hand_weapon', name: 'Hand Weapon, Blocking', category: 'magic_weapon', description: 'Block the blow when losing a fight. Take no damage.', effects: '{"damage_modifier":0,"blocking":true}', hasUses: true, maxUses: 1),
      (itemKey: 'blocking_two_handed_weapon', name: 'Two-Handed Weapon, Blocking', category: 'magic_weapon', description: 'Block the blow when losing a fight. Take no damage.', effects: '{"damage_modifier":2,"blocking":true}', hasUses: true, maxUses: 1),
      // Magic Items (sample)
      (itemKey: 'gemstone_spellfire', name: 'Gemstone of Spellfire', category: 'magic_item', description: 'Cast one spell without expending it for the scenario.', effects: '{"re_cast_spell":true}', hasUses: true, maxUses: 1),
      (itemKey: 'sunfire_pendant', name: 'Sunfire Pendant', category: 'magic_item', description: 'Attacks vs undead count as magic. Undead in combat suffer -2 Fight and -2 Armour.', effects: '{"undead_magic":true,"undead_penalty":-2}', hasUses: true, maxUses: 3),
      (itemKey: 'herb_pouch', name: 'Herb Pouch', category: 'magic_item', description: 'Takes one item slot but holds two herbs.', effects: '{"herb_slots":2}', hasUses: false, maxUses: null),
      (itemKey: 'book_of_lore', name: 'Book of Lore', category: 'magic_item', description: '+2 to all Ancient Lore and Read Runes Skill Rolls.', effects: '{"ancient_lore_bonus":2,"read_runes_bonus":2}', hasUses: false, maxUses: null),
      (itemKey: 'enchanted_lockpicks', name: 'Enchanted Lockpicks', category: 'magic_item', description: '+5 to any Pick Lock Skill Roll.', effects: '{"pick_lock_bonus":5}', hasUses: true, maxUses: 5),
      (itemKey: 'greyleaf_cloak', name: 'Greyleaf Cloak', category: 'magic_item', description: '+2 to all Stealth Rolls.', effects: '{"stealth_bonus":2}', hasUses: false, maxUses: null),
      (itemKey: 'gauntlets_of_strength', name: 'Gauntlets of Strength', category: 'magic_item', description: '+5 to any Strength Roll.', effects: '{"strength_bonus":5}', hasUses: true, maxUses: 5),
      (itemKey: 'amulet_of_leadership', name: 'Amulet of Leadership', category: 'magic_item', description: '+5 to Recruitment Point Total when recruiting.', effects: '{"rp_bonus":5}', hasUses: false, maxUses: null),
      (itemKey: 'gloves_of_climbing', name: 'Gloves of Climbing', category: 'magic_item', description: '+5 to any Climb Roll.', effects: '{"climb_bonus":5}', hasUses: true, maxUses: 5),
      (itemKey: 'eagle_eye_brooch', name: 'Eagle-eye Brooch', category: 'magic_item', description: '+2 to all Perception Skill Rolls.', effects: '{"perception_bonus":2}', hasUses: false, maxUses: null),
      (itemKey: 'ring_of_teleportation', name: 'Ring of Teleportation', category: 'magic_item', description: 'Move 10" in any direction to a spot in line of sight.', effects: '{"teleport_distance":10}', hasUses: true, maxUses: 1),
      (itemKey: 'boots_of_soft_tread', name: 'Boots of Soft Tread', category: 'magic_item', description: 'Ignore movement penalties for rough ground for rest of turn.', effects: '{"ignore_rough_ground":true}', hasUses: true, maxUses: 2),
      (itemKey: 'cloak_of_invisibility', name: 'Cloak of Invisibility', category: 'magic_item', description: 'No evil creature will force combat. +8 to Stealth Rolls.', effects: '{"stealth_bonus":8,"no_combat":true}', hasUses: true, maxUses: 2),
      (itemKey: 'fishglass', name: 'Fishglass', category: 'magic_item', description: 'Automatically pass all Swimming Rolls.', effects: '{"auto_swim":true}', hasUses: true, maxUses: 1),
      (itemKey: 'gemstone_heartlight', name: 'Gemstone of Heartlight', category: 'magic_item', description: 'Gain an extra action (max 3 per activation).', effects: '{"extra_action":true}', hasUses: true, maxUses: 1),
      (itemKey: 'spell_ring', name: 'Spell Ring', category: 'magic_item', description: 'Choose one spell. Wear to cast once. Ring destroyed after use.', effects: '{"choose_spell":true}', hasUses: true, maxUses: 1),
      (itemKey: 'tool_kit', name: 'Tool Kit', category: 'magic_item', description: '+2 to all Armoury and Traps Skill Rolls.', effects: '{"armoury_bonus":2,"traps_bonus":2}', hasUses: false, maxUses: null),
      (itemKey: 'spell_shield_pendant', name: 'Spell-shield Pendant', category: 'magic_item', description: 'Cancel a spell after failing Will Roll.', effects: '{"cancel_spell":true}', hasUses: true, maxUses: 1),
      (itemKey: 'fireball_orb', name: 'Fireball Orb', category: 'magic_item', description: '+5 elemental magic shooting attack to all figures within 2" of impact point.', effects: '{"fireball_damage":5,"radius":2}', hasUses: true, maxUses: 1),
      (itemKey: 'fate_stone', name: 'Fate Stone', category: 'magic_item', description: 'Re-roll any one die roll.', effects: '{"reroll":true}', hasUses: true, maxUses: 1),
      // Herbs and Potions
      ...herbsAndPotions.map((h) => (
        itemKey: h.key,
        name: h.name,
        category: 'herb_potion',
        description: h.description,
        effects: h.effects,
        hasUses: true,
        maxUses: 1,
      )),
    ];

    await batch((batch) {
      batch.insertAll(
        equipment,
        equipmentData.map((e) => EquipmentCompanion.insert(
              itemKey: e.itemKey,
              name: e.name,
              category: e.category,
              description: Value(e.description),
              effects: Value(e.effects),
              hasUses: Value(e.hasUses),
              maxUses: Value(e.maxUses),
            )),
      );
    });
  }

  // Migrate existing equipment effects to include basic equipment stats
  Future<void> _migrateEquipmentEffects() async {
    for (final item in magicItemsList) {
      await (update(equipment)..where((e) => e.itemKey.equals(item.key)))
        .write(EquipmentCompanion(
          effects: Value(item.effects),
        ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rangers_sd.sqlite'));
    return NativeDatabase(file);
  });
}
