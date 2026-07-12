class MagicItem {
  const MagicItem({
    required this.key,
    required this.name,
    required this.description,
    required this.category,
    required this.effects,
    this.maxUses,
    this.replacesWeaponType,
  });

  final String key;
  final String name;
  final String description;
  final String category; // 'magic_weapon', 'magic_armour', 'magic_item'
  final String effects; // JSON string with mechanical effects
  final int? maxUses;
  final String? replacesWeaponType; // For Light weapons
}

const List<MagicItem> magicItemsList = [
  // Magic Weapons (reusable, +1 Fight when activated)
  MagicItem(
    key: 'magic_hand_weapon',
    name: 'Hand Weapon, Magic',
    description: 'At any point, the wielder can declare activating it. Weapon counts as magic and gives +1 Fight for the rest of the game.',
    category: 'magic_weapon',
    effects: '{"fight_bonus":1,"magic":true}',
    maxUses: 5,
    replacesWeaponType: 'hand_weapon',
  ),
  MagicItem(
    key: 'magic_two_handed_weapon',
    name: 'Two-Handed Weapon, Magic',
    description: 'At any point, the wielder can declare activating it. Weapon counts as magic and gives +1 Fight for the rest of the game.',
    category: 'magic_weapon',
    effects: '{"fight_bonus":1,"magic":true}',
    maxUses: 5,
    replacesWeaponType: 'two_handed_weapon',
  ),
  MagicItem(
    key: 'magic_bow',
    name: 'Bow, Magic',
    description: 'At any point, the wielder can declare activating it. Weapon counts as magic and gives +1 Fight for the rest of the game.',
    category: 'magic_weapon',
    effects: '{"fight_bonus":1,"magic":true}',
    maxUses: 5,
    replacesWeaponType: 'bow',
  ),
  MagicItem(
    key: 'magic_crossbow',
    name: 'Crossbow, Magic',
    description: 'At any point, the wielder can declare activating it. Weapon counts as magic and gives +1 Fight for the rest of the game.',
    category: 'magic_weapon',
    effects: '{"fight_bonus":1,"magic":true}',
    maxUses: 5,
    replacesWeaponType: 'crossbow',
  ),
  MagicItem(
    key: 'magic_staff',
    name: 'Staff, Magic',
    description: 'At any point, the wielder can declare activating it. Weapon counts as magic and gives +1 Fight for the rest of the game.',
    category: 'magic_weapon',
    effects: '{"fight_bonus":1,"magic":true}',
    maxUses: 5,
    replacesWeaponType: 'staff',
  ),
  // Light Weapons (don't take item slot)
  MagicItem(
    key: 'light_hand_weapon',
    name: 'Hand Weapon, Light',
    description: 'Made of precious alloys, significantly lighter but just as strong. Does not take up an item slot. May only carry one Light item at a time.',
    category: 'magic_weapon',
    effects: '{"light":true}',
    replacesWeaponType: 'hand_weapon',
  ),
  MagicItem(
    key: 'light_two_handed_weapon',
    name: 'Two-Handed Weapon, Light',
    description: 'Made of precious alloys, significantly lighter but just as strong. Does not take up an item slot. May only carry one Light item at a time.',
    category: 'magic_weapon',
    effects: '{"light":true}',
    replacesWeaponType: 'two_handed_weapon',
  ),
  MagicItem(
    key: 'light_dagger',
    name: 'Dagger, Light',
    description: 'Made of precious alloys, significantly lighter but just as strong. Does not take up an item slot. May only carry one Light item at a time.',
    category: 'magic_weapon',
    effects: '{"light":true}',
    replacesWeaponType: 'dagger',
  ),
  MagicItem(
    key: 'light_throwing_knife',
    name: 'Throwing Knife, Light',
    description: 'Made of precious alloys, significantly lighter but just as strong. Does not take up an item slot. May only carry one Light item at a time.',
    category: 'magic_weapon',
    effects: '{"light":true}',
    replacesWeaponType: 'throwing_knife',
  ),
  // Brightness Armour (add +5 to Fight Roll vs shooting)
  MagicItem(
    key: 'brightness_shield',
    name: 'Shield, Brightness',
    description: 'Any time the user is the target of a shooting attack, add +5 to his Fight Roll. Must be declared before dice are rolled.',
    category: 'magic_armour',
    effects: '{"brightness":true}',
    maxUses: 5,
  ),
  MagicItem(
    key: 'brightness_light_armour',
    name: 'Light Armour, Brightness',
    description: 'Any time the user is the target of a shooting attack, add +5 to his Fight Roll. Must be declared before dice are rolled.',
    category: 'magic_armour',
    effects: '{"brightness":true}',
    maxUses: 5,
  ),
  MagicItem(
    key: 'brightness_heavy_armour',
    name: 'Heavy Armour, Brightness',
    description: 'Any time the user is the target of a shooting attack, add +5 to his Fight Roll. Must be declared before dice are rolled.',
    category: 'magic_armour',
    effects: '{"brightness":true}',
    maxUses: 5,
  ),
  // Elemental Strike (additional 5 elemental magic damage)
  MagicItem(
    key: 'elemental_strike_hand',
    name: 'Hand Weapon, Elemental Strike',
    description: 'Any time the wielder wins a fight and causes at least 1 point of damage, he may choose to do an additional 5 points of elemental magic damage.',
    category: 'magic_weapon',
    effects: '{"elemental_strike":5}',
    maxUses: 3,
    replacesWeaponType: 'hand_weapon',
  ),
  MagicItem(
    key: 'elemental_strike_two_handed',
    name: 'Two-Handed Weapon, Elemental Strike',
    description: 'Any time the wielder wins a fight and causes at least 1 point of damage, he may choose to do an additional 5 points of elemental magic damage.',
    category: 'magic_weapon',
    effects: '{"elemental_strike":5}',
    maxUses: 3,
    replacesWeaponType: 'two_handed_weapon',
  ),
  MagicItem(
    key: 'elemental_strike_staff',
    name: 'Staff, Elemental Strike',
    description: 'Any time the wielder wins a fight and causes at least 1 point of damage, he may choose to do an additional 5 points of elemental magic damage.',
    category: 'magic_weapon',
    effects: '{"elemental_strike":5}',
    maxUses: 3,
    replacesWeaponType: 'staff',
  ),
  // Blocking (block blow when losing, take no damage)
  MagicItem(
    key: 'blocking_shield',
    name: 'Shield, Blocking',
    description: 'Any time the user loses a fight in hand-to-hand combat, he may use the item to block the blow. The user still loses the fight but takes no damage.',
    category: 'magic_armour',
    effects: '{"blocking":true}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'blocking_light_armour',
    name: 'Light Armour, Blocking',
    description: 'Any time the user loses a fight in hand-to-hand combat, he may use the item to block the blow. The user still loses the fight but takes no damage.',
    category: 'magic_armour',
    effects: '{"blocking":true}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'blocking_heavy_armour',
    name: 'Heavy Armour, Blocking',
    description: 'Any time the user loses a fight in hand-to-hand combat, he may use the item to block the blow. The user still loses the fight but takes no damage.',
    category: 'magic_armour',
    effects: '{"blocking":true}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'blocking_hand_weapon',
    name: 'Hand Weapon, Blocking',
    description: 'Any time the user loses a fight in hand-to-hand combat, he may use the item to block the blow. The user still loses the fight but takes no damage.',
    category: 'magic_weapon',
    effects: '{"blocking":true}',
    maxUses: 1,
    replacesWeaponType: 'hand_weapon',
  ),
  MagicItem(
    key: 'blocking_two_handed_weapon',
    name: 'Two-Handed Weapon, Blocking',
    description: 'Any time the user loses a fight in hand-to-hand combat, he may use the item to block the blow. The user still loses the fight but takes no damage.',
    category: 'magic_weapon',
    effects: '{"blocking":true}',
    maxUses: 1,
    replacesWeaponType: 'two_handed_weapon',
  ),
  // Unique Magic Items
  MagicItem(
    key: 'gemstone_spellfire',
    name: 'Gemstone of Spellfire',
    description: 'A figure possessing spells may use this gemstone to cast one of those spells without expending that spell for the scenario.',
    category: 'magic_item',
    effects: '{"re_cast_spell":true}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'sunfire_pendant',
    name: 'Sunfire Pendant',
    description: 'A figure wearing this pendant may activate it as a free action. For the rest of the game, all attacks made while in combat with undead count as magic. Furthermore, all undead in combat suffer -2 Fight and -2 Armour.',
    category: 'magic_item',
    effects: '{"undead_magic":true,"undead_penalty":-2}',
    maxUses: 3,
  ),
  MagicItem(
    key: 'herb_pouch',
    name: 'Herb Pouch',
    description: 'The herb pouch takes up one item slot, but can hold two herbs, essentially allowing the figure to carry two herbs in one item slot.',
    category: 'magic_item',
    effects: '{"herb_slots":2}',
  ),
  MagicItem(
    key: 'book_of_lore',
    name: 'Book of Lore',
    description: 'A figure carrying a book of lore receives +2 to all Ancient Lore and Read Runes Skill Rolls.',
    category: 'magic_item',
    effects: '{"ancient_lore_bonus":2,"read_runes_bonus":2}',
  ),
  MagicItem(
    key: 'enchanted_lockpicks',
    name: 'Enchanted Lockpicks',
    description: 'A figure may use this item to gain a +5 to any Pick Lock Skill Roll. Must choose whether to use before the roll is made.',
    category: 'magic_item',
    effects: '{"pick_lock_bonus":5}',
    maxUses: 5,
  ),
  MagicItem(
    key: 'greyleaf_cloak',
    name: 'Greyleaf Cloak',
    description: 'A figure wearing this cloak receives +2 to all Stealth Rolls.',
    category: 'magic_item',
    effects: '{"stealth_bonus":2}',
  ),
  MagicItem(
    key: 'gauntlets_of_strength',
    name: 'Gauntlets of Strength',
    description: 'A figure may use this item to gain a +5 to any Strength Rolls. Must choose whether to use before the roll is made.',
    category: 'magic_item',
    effects: '{"strength_bonus":5}',
    maxUses: 5,
  ),
  MagicItem(
    key: 'amulet_of_leadership',
    name: 'Amulet of Leadership',
    description: 'If a ranger wears this amulet, he may add +5 to his Recruitment Point Total when recruiting companions.',
    category: 'magic_item',
    effects: '{"rp_bonus":5}',
  ),
  MagicItem(
    key: 'gloves_of_climbing',
    name: 'Gloves of Climbing',
    description: 'A figure may use this item to gain +5 to any Climb Roll. Must choose whether to use before the roll is made.',
    category: 'magic_item',
    effects: '{"climb_bonus":5}',
    maxUses: 5,
  ),
  MagicItem(
    key: 'eagle_eye_brooch',
    name: 'Eagle-eye Brooch',
    description: 'A figure wearing this item gains +2 to all Perception Skill Rolls.',
    category: 'magic_item',
    effects: '{"perception_bonus":2}',
  ),
  MagicItem(
    key: 'ring_of_teleportation',
    name: 'Ring of Teleportation',
    description: 'A figure may spend an action to use this ring. Immediately move the figure 10" in any direction, so long as the destination spot is within line of sight.',
    category: 'magic_item',
    effects: '{"teleport_distance":10}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'boots_of_soft_tread',
    name: 'Boots of Soft Tread',
    description: 'A figure wearing these boots may activate them during its activation. For the rest of the turn, the figure can ignore any movement penalties for rough ground.',
    category: 'magic_item',
    effects: '{"ignore_rough_ground":true}',
    maxUses: 2,
  ),
  MagicItem(
    key: 'cloak_of_invisibility',
    name: 'Cloak of Invisibility',
    description: 'A figure may use this item at any time. For the rest of the turn, no evil creature will force combat with the figure. Furthermore, do not take this figure into account when determining the actions of evil creatures. The figure receives +8 to all Stealth Rolls while invisible.',
    category: 'magic_item',
    effects: '{"stealth_bonus":8,"no_combat":true}',
    maxUses: 2,
  ),
  MagicItem(
    key: 'fishglass',
    name: 'Fishglass',
    description: 'A figure that swallows this small marble automatically passes all Swimming Rolls for the remainder of the game.',
    category: 'magic_item',
    effects: '{"auto_swim":true}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'gemstone_heartlight',
    name: 'Gemstone of Heartlight',
    description: 'A figure carrying this gem may discard the gem during its activation to gain an extra action. This may not take a figure above three actions during its activation.',
    category: 'magic_item',
    effects: '{"extra_action":true}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'spell_ring',
    name: 'Spell Ring',
    description: 'Choose one spell from the Spell List when this item is found. The wearer may spend an action to cast that spell. Afterwards, the ring is destroyed.',
    category: 'magic_item',
    effects: '{"choose_spell":true}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'tool_kit',
    name: 'Tool Kit',
    description: 'A figure carrying a tool kit gains +2 to all Armoury and Traps Skill Rolls.',
    category: 'magic_item',
    effects: '{"armoury_bonus":2,"traps_bonus":2}',
  ),
  MagicItem(
    key: 'spell_shield_pendant',
    name: 'Spell-shield Pendant',
    description: 'A figure wearing this pendant, that is forced to make a Will Roll to resist a spell, may discard this pendant and cancel the spell. This item can be used after the Will Roll is made.',
    category: 'magic_item',
    effects: '{"cancel_spell":true}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'fireball_orb',
    name: 'Fireball Orb',
    description: 'A figure may spend an action to throw this orb anywhere within 10". Every figure within 2" of the point of impact immediately suffers a +5 elemental magic shooting attack.',
    category: 'magic_item',
    effects: '{"fireball_damage":5,"radius":2}',
    maxUses: 1,
  ),
  MagicItem(
    key: 'fate_stone',
    name: 'Fate Stone',
    description: 'A figure carrying this stone may use it to re-roll any one die roll that it makes.',
    category: 'magic_item',
    effects: '{"reroll":true}',
    maxUses: 1,
  ),
];

/// Look up a magic item by key
MagicItem? getMagicItem(String key) {
  for (final item in magicItemsList) {
    if (item.key == key) return item;
  }
  return null;
}

/// Get all magic weapons
List<MagicItem> get magicWeapons =>
    magicItemsList.where((i) => i.category == 'magic_weapon').toList();

/// Get all magic armour
List<MagicItem> get magicArmour =>
    magicItemsList.where((i) => i.category == 'magic_armour').toList();

/// Get all unique magic items
List<MagicItem> get uniqueMagicItems =>
    magicItemsList.where((i) => i.category == 'magic_item').toList();
