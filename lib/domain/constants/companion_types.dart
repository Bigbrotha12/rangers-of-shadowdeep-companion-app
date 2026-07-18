class CompanionType {
  const CompanionType({
    required this.key,
    required this.name,
    required this.description,
    required this.rpCost,
    required this.move,
    required this.fight,
    required this.shoot,
    required this.armour,
    required this.will,
    required this.health,
    required this.notes,
    required this.isAnimal,
    this.baseSkills = const {},
    this.allowedSkillRolls,
    this.specialRules,
    this.allowedWeaponTypes = const [],
    this.allowedArmourTypes = const [],
  });

  final String key;
  final String name;
  final String description;
  final int rpCost;
  final int move;
  final int fight;
  final int shoot;
  final int armour;
  final int will;
  final int health;
  final String notes;
  final bool isAnimal;
  final Map<String, int> baseSkills;
  final List<String>? allowedSkillRolls;
  final String? specialRules;
  final List<String> allowedWeaponTypes;
  final List<String> allowedArmourTypes;
}

const List<CompanionType> companionTypes = [
  CompanionType(
    key: 'arcanist',
    name: 'Arcanist',
    description: 'Arcanists are students of ancient lore and languages. Although they are not the best fighters, their knowledge of myths and legends and their ability to translate ancient writings can often prove vital on missions in the Shadow Deep.',
    rpCost: 15,
    move: 6,
    fight: 2,
    shoot: 0,
    armour: 10,
    will: 2,
    health: 10,
    notes: 'Hand Weapon, Ancient Lore +5, Read Runes +5',
    isAnimal: false,
    baseSkills: {'ancient_lore': 5, 'read_runes': 5},
    allowedWeaponTypes: ['hand_weapon'],
  ),
  CompanionType(
    key: 'archer',
    name: 'Archer',
    description: 'Hand-to-hand combat is always a risky proposition – better to shoot down evil creatures before they get anywhere near you. A ranger can choose an archer armed with either a bow or a crossbow.',
    rpCost: 20,
    move: 6,
    fight: 2,
    shoot: 2,
    armour: 11,
    will: 1,
    health: 10,
    notes: 'Bow OR Crossbow, Dagger, Light Armour, Quiver',
    isAnimal: false,
    allowedWeaponTypes: ['bow', 'crossbow', 'dagger'],
    allowedArmourTypes: ['light_armour'],
  ),
  CompanionType(
    key: 'barbarian',
    name: 'Barbarian',
    description: 'Born and bred beyond the bounds of civilized regions, Barbarians are fearsome warriors who rely on natural strength and toughness instead of armour to win their battles.',
    rpCost: 35,
    move: 6,
    fight: 4,
    shoot: 0,
    armour: 11,
    will: 3,
    health: 14,
    notes: 'Hand Weapon, Shield, Strength +5',
    isAnimal: false,
    baseSkills: {'strength': 5},
    allowedWeaponTypes: ['hand_weapon'],
    allowedArmourTypes: ['shield'],
  ),
  CompanionType(
    key: 'conjuror',
    name: 'Conjuror',
    description: 'While most wizards lock themselves away in libraries, conjurors like to put their magic abilities to practical use. Before each scenario, the player may select two spells for the conjuror (or three spells for an extra cost of +10RP).',
    rpCost: 20,
    move: 6,
    fight: 0,
    shoot: 0,
    armour: 10,
    will: 3,
    health: 12,
    notes: 'Staff OR Hand Weapon, 2 Spells, 3rd Spell (+10 RP)',
    isAnimal: false,
    specialRules: 'Can select 2 spells (or 3 for +10 RP). Casts spells using same rules as rangers.',
    allowedWeaponTypes: ['staff', 'hand_weapon'],
  ),
  CompanionType(
    key: 'guardsman',
    name: 'Guardsman',
    description: 'One of the soldiers of the kingdom, trained to fight with larger two-handed weapons, such as halberds, battle axes, and two-handed swords.',
    rpCost: 20,
    move: 6,
    fight: 3,
    shoot: 0,
    armour: 11,
    will: 2,
    health: 12,
    notes: 'Two-Handed Weapon, Light Armour',
    isAnimal: false,
    allowedWeaponTypes: ['two_handed_weapon'],
    allowedArmourTypes: ['light_armour'],
  ),
  CompanionType(
    key: 'hound',
    name: 'Hound',
    description: 'By far the most common animal companion is the hound. These dogs are truly man\'s best friend. Faithful to the last, they will gladly lay their lives down for their masters.',
    rpCost: 5,
    move: 8,
    fight: 0,
    shoot: 0,
    armour: 10,
    will: -2,
    health: 6,
    notes: 'Animal, Cannot Carry Treasure or Items, Limited Skill Rolls',
    isAnimal: true,
    allowedSkillRolls: ['acrobatics', 'climb', 'perception', 'stealth', 'swim', 'track'],
  ),
  CompanionType(
    key: 'warhound',
    name: 'Warhound',
    description: 'A larger, more aggressive variety of hound bred for combat.',
    rpCost: 10,
    move: 8,
    fight: 1,
    shoot: 0,
    armour: 10,
    will: 2,
    health: 8,
    notes: 'Animal, Cannot Carry Treasure or Items, Limited Skill Rolls',
    isAnimal: true,
    allowedSkillRolls: ['acrobatics', 'climb', 'perception', 'stealth', 'swim', 'track'],
  ),
  CompanionType(
    key: 'bloodhound',
    name: 'Bloodhound',
    description: 'A tracking hound with an exceptional nose for scent. The bloodhound has Tracking +5, and whenever a ranger makes a Tracking Roll with his hound within 2" he receives a +2 bonus to the roll.',
    rpCost: 10,
    move: 8,
    fight: 0,
    shoot: 0,
    armour: 10,
    will: -2,
    health: 6,
    notes: 'Animal, Cannot Carry Treasure or Items, Limited Skill Rolls, Tracking +5, Ranger Tracking Bonus',
    isAnimal: true,
    baseSkills: {'track': 5},
    allowedSkillRolls: ['acrobatics', 'climb', 'perception', 'stealth', 'swim', 'track'],
    specialRules: 'Ranger gets +2 to Tracking Rolls when bloodhound is within 2".',
  ),
  CompanionType(
    key: 'knight',
    name: 'Knight',
    description: 'The elite fighting men of the kingdom, knights are heavily armoured and highly skilled in melee combat.',
    rpCost: 35,
    move: 5,
    fight: 4,
    shoot: 0,
    armour: 13,
    will: 2,
    health: 12,
    notes: 'Hand Weapon, Shield, Heavy Armour, Strength +4',
    isAnimal: false,
    baseSkills: {'strength': 4},
    allowedWeaponTypes: ['hand_weapon'],
    allowedArmourTypes: ['shield', 'heavy_armour'],
  ),
  CompanionType(
    key: 'man_at_arms',
    name: 'Man-at-Arms',
    description: 'The basic soldier of the kingdom, the man-at-arms is trained and equipped for fighting the enemy at close quarters.',
    rpCost: 20,
    move: 6,
    fight: 3,
    shoot: 0,
    armour: 12,
    will: 2,
    health: 12,
    notes: 'Hand Weapon, Shield, Light Armour',
    isAnimal: false,
    allowedWeaponTypes: ['hand_weapon'],
    allowedArmourTypes: ['shield', 'light_armour'],
  ),
  CompanionType(
    key: 'raptor',
    name: 'Raptor',
    description: 'Some rangers bring trained hawks, falcons, or other birds of prey with them on their missions. Although these animals are small and fragile, their ability to fly allows them to ignore all movement penalties for terrain.',
    rpCost: 10,
    move: 9,
    fight: 0,
    shoot: 0,
    armour: 14,
    will: 3,
    health: 1,
    notes: 'Animal, Cannot Carry Treasure or Items, Limited Skill Rolls, Perception +4',
    isAnimal: true,
    baseSkills: {'perception': 4},
    allowedSkillRolls: ['acrobatics', 'perception', 'stealth'],
    specialRules: 'Automatically passes Climb and Swim Rolls. Ignores terrain movement penalties.',
  ),
  CompanionType(
    key: 'recruit',
    name: 'Recruit',
    description: 'Recruits are the newest members of the Rangers. They are generally young, unskilled, and sometimes as much trouble as they are worth. Sometimes, however, they are all that is available.',
    rpCost: 10,
    move: 6,
    fight: 2,
    shoot: 0,
    armour: 10,
    will: 0,
    health: 10,
    notes: 'Hand Weapon',
    isAnimal: false,
    allowedWeaponTypes: ['hand_weapon'],
  ),
  CompanionType(
    key: 'rogue',
    name: 'Rogue',
    description: 'Rogues aren\'t the best fighters, but they are highly skilled individuals, who can be invaluable if you need a lock picked or a trap disarmed.',
    rpCost: 20,
    move: 7,
    fight: 1,
    shoot: 1,
    armour: 10,
    will: 1,
    health: 10,
    notes: 'Dagger, Throwing Knife, Climb +2, Perception +2, Pick Lock +5, Traps +5, Stealth +5',
    isAnimal: false,
    baseSkills: {'climb': 2, 'perception': 2, 'pick_lock': 5, 'traps': 5, 'stealth': 5},
    allowedWeaponTypes: ['dagger', 'throwing_knife'],
  ),
  CompanionType(
    key: 'savage',
    name: 'Savage',
    description: 'Like barbarians, savages are ferocious fighters who like to wade into the thick of a battle with brutal two-handed weapons.',
    rpCost: 35,
    move: 6,
    fight: 4,
    shoot: 0,
    armour: 10,
    will: 3,
    health: 14,
    notes: 'Two-Handed Weapon, Strength +5',
    isAnimal: false,
    baseSkills: {'strength': 5},
    allowedWeaponTypes: ['two_handed_weapon'],
  ),
  CompanionType(
    key: 'swordsman',
    name: 'Swordsman',
    description: 'Swordsmen are highly trained in the art of wielding a blade and have learned to defend themselves without recourse to heavy armour or shields.',
    rpCost: 25,
    move: 6,
    fight: 4,
    shoot: 0,
    armour: 11,
    will: 2,
    health: 12,
    notes: 'Hand Weapon, Dagger, Light Armour',
    isAnimal: false,
    allowedWeaponTypes: ['hand_weapon', 'dagger'],
    allowedArmourTypes: ['light_armour'],
  ),
  CompanionType(
    key: 'templar',
    name: 'Templar',
    description: 'A subclass of knights that have trained in fighting with two-handed weapons. They are usually called upon to fight larger creatures such as trolls and ogres.',
    rpCost: 35,
    move: 5,
    fight: 4,
    shoot: 0,
    armour: 12,
    will: 2,
    health: 12,
    notes: 'Two-Handed Weapon, Heavy Armour, Strength +4',
    isAnimal: false,
    baseSkills: {'strength': 4},
    allowedWeaponTypes: ['two_handed_weapon'],
    allowedArmourTypes: ['heavy_armour'],
  ),
  CompanionType(
    key: 'tracker',
    name: 'Tracker',
    description: 'Recruited from the countryside in times of need, these specialist huntsmen are not warriors by trade, but they are skilled with a bow and useful for staying on the trail of the agents of evil.',
    rpCost: 30,
    move: 7,
    fight: 2,
    shoot: 2,
    armour: 11,
    will: 2,
    health: 12,
    notes: 'Staff, Bow, Quiver, Light Armour, Tracking +5',
    isAnimal: false,
    baseSkills: {'track': 5},
    allowedWeaponTypes: ['staff', 'bow'],
    allowedArmourTypes: ['light_armour'],
  ),
];

/// Look up a companion type by key
CompanionType? getCompanionType(String key) {
  for (final type in companionTypes) {
    if (type.key == key) return type;
  }
  return null;
}

/// Map a database companion_type_id to its type key
String companionTypeKeyFromId(int id) {
  switch (id) {
    case 1: return 'arcanist';
    case 2: return 'archer';
    case 3: return 'barbarian';
    case 4: return 'conjuror';
    case 5: return 'guardsman';
    case 6: return 'hound';
    case 7: return 'warhound';
    case 8: return 'bloodhound';
    case 9: return 'knight';
    case 10: return 'man_at_arms';
    case 11: return 'raptor';
    case 12: return 'recruit';
    case 13: return 'rogue';
    case 14: return 'savage';
    case 15: return 'swordsman';
    case 16: return 'templar';
    case 17: return 'tracker';
    default: return 'recruit';
  }
}

/// Get all non-animal companion types
List<CompanionType> get humanCompanionTypes =>
    companionTypes.where((c) => !c.isAnimal).toList();

/// Get all animal companion types
List<CompanionType> get animalCompanionTypes =>
    companionTypes.where((c) => c.isAnimal).toList();
