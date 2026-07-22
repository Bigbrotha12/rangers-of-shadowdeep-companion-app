class BasicEquipment {
  const BasicEquipment({
    required this.key,
    required this.name,
    required this.description,
    required this.category,
    required this.effects,
    this.isTwoHanded = false,
    this.isLight = false,
  });

  final String key;
  final String name;
  final String description;
  final String category; // 'weapon', 'armour', 'gear'
  final String effects; // JSON string with mechanical effects
  final bool isTwoHanded;
  final bool isLight;
}

const List<BasicEquipment> basicEquipmentList = [
  BasicEquipment(
    key: 'bow',
    name: 'Bow',
    description: 'The favoured missile weapon of rangers, bows may be loaded and fired in a single action. Maximum range 24". No damage modifier. Requires quiver.',
    category: 'weapon',
    effects: '{"damage_modifier":0,"range":24,"reload":"single_action","requires":"quiver"}',
  ),
  BasicEquipment(
    key: 'crossbow',
    name: 'Crossbow',
    description: 'Takes one action to load and one action to fire. +2 damage modifier, range 24". Requires quiver. Assumed to start loaded.',
    category: 'weapon',
    effects: '{"damage_modifier":2,"range":24,"reload":"load_and_fire","requires":"quiver"}',
  ),
  BasicEquipment(
    key: 'dagger',
    name: 'Dagger',
    description: 'A knife not balanced for throwing. -1 damage modifier.',
    category: 'weapon',
    effects: '{"damage_modifier":-1}',
  ),
  BasicEquipment(
    key: 'hand_weapon',
    name: 'Hand Weapon',
    description: 'Swords, clubs, axes, maces, spears. No modifiers in combat.',
    category: 'weapon',
    effects: '{"damage_modifier":0}',
  ),
  BasicEquipment(
    key: 'two_handed_weapon',
    name: 'Two-Handed Weapon',
    description: 'Heavy melee weapons requiring two hands. +2 damage modifier.',
    category: 'weapon',
    effects: '{"damage_modifier":2}',
    isTwoHanded: true,
  ),
  BasicEquipment(
    key: 'throwing_knife',
    name: 'Throwing Knife',
    description: 'Small throwing weapons. One shooting attack per knife per game, range 8", -1 damage. Can be used as backup melee weapon.',
    category: 'weapon',
    effects: '{"damage_modifier":-1,"range":8,"shots_per_game":1}',
  ),
  BasicEquipment(
    key: 'staff',
    name: 'Staff',
    description: 'Defensive properties. -1 damage modifier, but opponent also gets -1 damage modifier in hand-to-hand.',
    category: 'weapon',
    effects: '{"damage_modifier":-1,"opponent_damage_modifier":-1}',
    isTwoHanded: true,
  ),
  BasicEquipment(
    key: 'light_armour',
    name: 'Light Armour',
    description: 'Leather or nonmetal materials. +1 to Armour.',
    category: 'armour',
    effects: '{"armour_bonus":1}',
    isLight: true,
  ),
  BasicEquipment(
    key: 'heavy_armour',
    name: 'Heavy Armour',
    description: 'Mostly metal construction. +2 to Armour, -1 to Move.',
    category: 'armour',
    effects: '{"armour_bonus":2,"move_penalty":-1}',
  ),
  BasicEquipment(
    key: 'shield',
    name: 'Shield',
    description: '+1 to Armour. Cannot carry two-handed weapon or staff.',
    category: 'gear',
    effects: '{"armour_bonus":1}',
  ),
  BasicEquipment(
    key: 'quiver',
    name: 'Quiver',
    description: 'Required for bow/crossbow attacks. Can carry one piece of magic ammunition without taking an item slot.',
    category: 'gear',
    effects: '{}',
  ),
  BasicEquipment(
    key: 'rope',
    name: 'Rope',
    description: 'At top of vertical structure, spend action to set rope. Any figure may use rope to climb without penalties.',
    category: 'gear',
    effects: '{}',
  ),
];

/// Look up basic equipment by key
BasicEquipment? getBasicEquipment(String key) {
  for (final item in basicEquipmentList) {
    if (item.key == key) return item;
  }
  return null;
}

/// Maximum equipment slots for a companion (non-animal)
const int maxCompanionEquipmentSlots = 2;
