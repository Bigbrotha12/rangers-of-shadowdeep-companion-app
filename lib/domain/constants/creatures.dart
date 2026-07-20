class CreatureDefinition {
  const CreatureDefinition({
    required this.key,
    required this.name,
    required this.description,
    required this.xpValue,
    required this.move,
    required this.fight,
    required this.shoot,
    required this.armour,
    required this.will,
    required this.health,
    required this.notes,
    this.specialRules = const [],
    this.variantLabel,
  });

  final String key;
  final String name;
  final String description;
  final int xpValue;
  final int move;
  final int fight;
  final int shoot;
  final int armour;
  final int will;
  final int health;
  final String notes;
  final List<String> specialRules;
  final String? variantLabel;
}

const List<CreatureDefinition> creatures = [
  CreatureDefinition(
    key: 'blood_bat',
    name: 'Blood Bat',
    description:
        'This large, highly aggressive species of bat is common in the Shadow Deep. While not overly dangerous individually, they usually attack their prey in small groups.',
    xpValue: 1,
    move: 8,
    fight: 1,
    shoot: 0,
    armour: 12,
    will: 3,
    health: 1,
    notes: 'Animal, Flying',
  ),
  CreatureDefinition(
    key: 'burrow_worm',
    name: 'Burrow Worm',
    description:
        'These giant worms can grow up to three feet in diameter and as much as twenty feet long, although most are significantly smaller. These creatures are capable of swiftly burrowing through the earth and are often used to attack strong points from beneath.',
    xpValue: 8,
    move: 5,
    fight: 3,
    shoot: 0,
    armour: 10,
    will: 3,
    health: 14,
    notes: 'Animal, Burrowing',
  ),
  CreatureDefinition(
    key: 'civilian',
    name: 'Civilian',
    description:
        'Sometimes during their adventures, the rangers will encounter ordinary folk who are not soldiers, adventurers, or monsters.',
    xpValue: 0,
    move: 6,
    fight: 0,
    shoot: 0,
    armour: 10,
    will: 0,
    health: 10,
    notes: 'Dagger',
  ),
  CreatureDefinition(
    key: 'darkroot_body',
    name: 'Darkroot Body',
    description:
        'These large plants are found all over the Shadow Deep, usually in dark corners. The immobile darkroot body is the main mass of the plant and is very difficult to damage with missile weapons.',
    xpValue: 6,
    move: 0,
    fight: 3,
    shoot: 0,
    armour: 14,
    will: 0,
    health: 18,
    notes: 'Missile Weapon Damage Maximum',
    variantLabel: 'Body',
    specialRules: ['Maximum damage from missile weapons is 2'],
  ),
  CreatureDefinition(
    key: 'darkroot_vine',
    name: 'Darkroot Vine',
    description:
        'Each darkroot vine is treated as a separate figure which can move about the table. If the darkroot body is killed, all the darkroot vines are immediately removed from the table.',
    xpValue: 0,
    move: 6,
    fight: 1,
    shoot: 0,
    armour: 10,
    will: 0,
    health: 6,
    notes: '',
    variantLabel: 'Vine',
  ),
  CreatureDefinition(
    key: 'flesh_golem',
    name: 'Flesh Golem',
    description:
        'Using the blackest of magic, some servants of the Shadow Deep can bind together the pieces of dead men and creatures to create horrific, undead monstrosities called flesh golems.',
    xpValue: 5,
    move: 5,
    fight: 4,
    shoot: 0,
    armour: 10,
    will: 0,
    health: 16,
    notes: 'Undead, Horrific (TN8)',
    specialRules: [
      'Horrific: any hero wishing to move into combat must first pass a Will Roll (TN8). If it fails, it moves to within 2" (or stays where it is) and its activation ends.',
    ],
  ),
  CreatureDefinition(
    key: 'giant_fly',
    name: 'Giant Fly',
    description:
        'Even before the coming of the Shadow Deep, these gigantic flying insects would occasionally threaten remote farmers. Recently, these huge insects have become more aggressive.',
    xpValue: 2,
    move: 6,
    fight: 0,
    shoot: 0,
    armour: 6,
    will: 0,
    health: 5,
    notes: 'Animal, Flying, Disease (TN8)',
    specialRules: ['Disease (TN8)'],
  ),
  CreatureDefinition(
    key: 'giant_rat',
    name: 'Giant Rat',
    description:
        'Giant Rats are a by-product of the evil corruptions of the Shadow Deep. Although numerous, dangerous, and often carrying disease, they are not intelligent.',
    xpValue: 2,
    move: 6,
    fight: 0,
    shoot: 0,
    armour: 6,
    will: 0,
    health: 1,
    notes: 'Animal, Disease (TN8)',
    specialRules: ['Disease (TN8)'],
  ),
  CreatureDefinition(
    key: 'giant_spider',
    name: 'Giant Spider',
    description:
        'These hairy arachnids vary in size, but most are comparable to a large dog. They possess only rudimentary intelligence, and while they are servants of the Shadow Deep, they are mainly used to cause chaos and corruption ahead of more organized attacks.',
    xpValue: 2,
    move: 6,
    fight: 0,
    shoot: 0,
    armour: 8,
    will: 0,
    health: 4,
    notes: 'Animal, Poison, No Movement Penalty for Rough Ground or Climbing',
    specialRules: ['Poison', 'No Movement Penalty for Rough Ground or Climbing'],
  ),
  CreatureDefinition(
    key: 'ghoul',
    name: 'Ghoul',
    description:
        'Ghouls are extremely common in the Shadow Deep. Created when a human eats tainted flesh, it is unknown if they are accidental creations or the deliberate policy of some evil intelligence.',
    xpValue: 3,
    move: 6,
    fight: 2,
    shoot: 0,
    armour: 10,
    will: 2,
    health: 10,
    notes: 'Undead',
  ),
  CreatureDefinition(
    key: 'ghoul_fiend',
    name: 'Ghoul Fiend',
    description:
        'Apparently, even ghouls have a hierarchy, and near the top sit the ghoul fiends. These creatures were once great and powerful warriors before they succumbed to undeath.',
    xpValue: 4,
    move: 6,
    fight: 3,
    shoot: 0,
    armour: 11,
    will: 6,
    health: 14,
    notes: 'Undead',
  ),
  CreatureDefinition(
    key: 'ghoul_flinger',
    name: 'Ghoul Flinger',
    description:
        'While most ghouls like to rush in and tear their prey limb from limb, the occasional ghoul will take a more indirect approach and attempt to bring down its food from a distance.',
    xpValue: 3,
    move: 6,
    fight: 1,
    shoot: 1,
    armour: 10,
    will: 2,
    health: 10,
    notes: 'Undead, Throw Bones',
    specialRules: [
      'Throw Bones: can make shooting attacks up to 10" with no damage modifier.',
    ],
  ),
  CreatureDefinition(
    key: 'ghoul_rotter',
    name: 'Ghoul Rotter',
    description:
        'For reasons unclear, there is at least one disease that affects the dead flesh of ghouls, causing them to slowly rot away. While good news in the long term, in the short term, it means these weaker ghouls are the source of a potentially nasty infection.',
    xpValue: 2,
    move: 6,
    fight: 1,
    shoot: 0,
    armour: 10,
    will: 0,
    health: 8,
    notes: 'Undead, Disease (TN14)',
    specialRules: ['Disease (TN14)'],
  ),
  CreatureDefinition(
    key: 'ghoul_snake',
    name: 'Ghoul Snake',
    description:
        'Although rarely encountered, it is possible for large snakes to succumb to the same taint as humans and develop into ghouls.',
    xpValue: 3,
    move: 5,
    fight: 2,
    shoot: 0,
    armour: 8,
    will: 0,
    health: 16,
    notes: 'Undead',
  ),
  CreatureDefinition(
    key: 'giant_snake',
    name: 'Giant Snake',
    description:
        'Giant serpents are, unfortunately, all too common in the evil realm. Generally, these creatures appear to be part of the natural ecosystem, preying on anything human and smaller.',
    xpValue: 3,
    move: 5,
    fight: 2,
    shoot: 0,
    armour: 8,
    will: 0,
    health: 10,
    notes: 'Animal, Amphibious (giant water snake), Poison (giant viper)',
    specialRules: [
      'Amphibious (giant water snake): no penalties for moving through water.',
      'Poison (giant viper): potent venom.',
    ],
  ),
  CreatureDefinition(
    key: 'gnoll_fighter',
    name: 'Gnoll Fighter',
    description:
        'Gnolls are hybrid creatures that appear as a cross between humans and either rats, dogs, or hyenas. Gnoll fighters are the most common frontline troops.',
    xpValue: 3,
    move: 6,
    fight: 2,
    shoot: 0,
    armour: 11,
    will: 0,
    health: 10,
    notes: 'Hand Weapon, Light Armour',
    variantLabel: 'Fighter',
  ),
  CreatureDefinition(
    key: 'gnoll_archer',
    name: 'Gnoll Archer',
    description:
        'Gnolls are hybrid creatures that appear as a cross between humans and either rats, dogs, or hyenas. Gnoll archers provide ranged support.',
    xpValue: 3,
    move: 6,
    fight: 1,
    shoot: 2,
    armour: 11,
    will: 0,
    health: 10,
    notes: 'Dagger, Bow or Crossbow, Quiver, Light Armour',
    variantLabel: 'Archer',
  ),
  CreatureDefinition(
    key: 'gnoll_sergeant',
    name: 'Gnoll Sergeant',
    description:
        'Gnolls are hybrid creatures that appear as a cross between humans and either rats, dogs, or hyenas. Gnoll sergeants lead small units into battle.',
    xpValue: 3,
    move: 6,
    fight: 3,
    shoot: 0,
    armour: 11,
    will: 0,
    health: 12,
    notes: 'Two-Handed Weapon, Light Armour',
    variantLabel: 'Sergeant',
  ),
  CreatureDefinition(
    key: 'gnoll_shaman',
    name: 'Gnoll Shaman',
    description:
        'Gnolls are hybrid creatures that appear as a cross between humans and either rats, dogs, or hyenas. Gnoll shamans use dark magic and poison to support their kin.',
    xpValue: 5,
    move: 6,
    fight: 1,
    shoot: 0,
    armour: 11,
    will: 5,
    health: 12,
    notes: 'Hand Weapon, Poison, Inspiring (+2 Will to all gnolls within 6")',
    variantLabel: 'Shaman',
    specialRules: [
      'Poison',
      'Inspiring: +2 Will to all gnolls within 6".',
    ],
  ),
  CreatureDefinition(
    key: 'ogre',
    name: 'Ogre',
    description:
        'Ogres are large, primitive humanoids. While not inherently evil, they have a tendency towards violence and cruelty which makes them extremely susceptible to the corrupting influence of the Shadow Deep.',
    xpValue: 5,
    move: 6,
    fight: 3,
    shoot: 0,
    armour: 12,
    will: 0,
    health: 14,
    notes: 'Large, Two-Handed Weapon',
    specialRules: ['Large'],
  ),
  CreatureDefinition(
    key: 'shadow_knight',
    name: 'Shadow Knight',
    description:
        'The elite warriors of the Shadow Deep are the heavily armoured, skull-faced Shadow Knights. Their magic nature makes them partially immune to non-magic weapons.',
    xpValue: 10,
    move: 6,
    fight: 4,
    shoot: 0,
    armour: 12,
    will: 0,
    health: 14,
    notes: 'Undead, Partial Immunity to Non-Magic Weapons',
    specialRules: [
      'If struck with a non-magic weapon, calculate damage normally, then halve it, rounding down.',
    ],
  ),
  CreatureDefinition(
    key: 'skeletal_knight',
    name: 'Skeletal Knight',
    description:
        'A few skeletons, usually those of fighting men, retain some of the martial ability and equipment that they possessed in life.',
    xpValue: 2,
    move: 6,
    fight: 3,
    shoot: 0,
    armour: 13,
    will: 0,
    health: 1,
    notes: 'Undead',
  ),
  CreatureDefinition(
    key: 'skeleton',
    name: 'Skeleton',
    description:
        'The evil of the Shadow Deep hates to waste any potential resource – even the bones of the long deceased are often used to further its aims.',
    xpValue: 1,
    move: 6,
    fight: 1,
    shoot: 0,
    armour: 10,
    will: 0,
    health: 1,
    notes: 'Undead',
  ),
  CreatureDefinition(
    key: 'swamp_zombie',
    name: 'Swamp Zombie',
    description:
        'Zombies that are reanimated while submerged in water often become a specific subtype known as the swamp zombie. These are nearly identical to normal zombies except that they are amphibious.',
    xpValue: 2,
    move: 4,
    fight: 0,
    shoot: 0,
    armour: 12,
    will: 0,
    health: 6,
    notes: 'Undead, Amphibious',
    specialRules: ['Amphibious: never make Swimming Rolls, no movement penalty for water.'],
  ),
  CreatureDefinition(
    key: 'terror_wing',
    name: 'Terror Wing',
    description:
        'Giant, demonic-looking creatures, terror wings stand nine feet tall, with horns, claws, and a pair of large wings sprouting from their backs. Terror wings are horrific to look upon.',
    xpValue: 20,
    move: 6,
    fight: 5,
    shoot: 0,
    armour: 14,
    will: 8,
    health: 16,
    notes: 'Horrific (TN12), Flying, Spellcaster',
    specialRules: [
      'Horrific: anyone wishing to move into combat must first pass a Will Roll (TN12).',
      'Flying: ignores all terrain penalties for movement.',
      'Spellcaster: can cast spells per scenario rules.',
    ],
  ),
  CreatureDefinition(
    key: 'tortured_soul',
    name: 'Tortured Soul',
    description:
        'These are the ghosts of people who have suffered greatly from the evils of the Shadow Deep. They roam around the dark lands, shouting their tortured cries.',
    xpValue: 10,
    move: 6,
    fight: 0,
    shoot: 0,
    armour: 0,
    will: 0,
    health: 0,
    notes: 'Undead, Will Sap, Will/Leadership Roll to Free',
    specialRules: [
      'Will Sap: all heroes suffer -2 Will while a tortured soul is on the table.',
      'Cannot be damaged or forced into combat.',
      'A hero in contact may spend an action to make a Will or Leadership Roll (TN20) to free the soul (gains 10 XP).',
    ],
  ),
  CreatureDefinition(
    key: 'troll',
    name: 'Troll',
    description:
        'These giant, hairy monsters are occasionally encountered in the wilds of Alladore but seem to have flourished in the Shadow Deep. They possess only rudimentary intelligence.',
    xpValue: 8,
    move: 4,
    fight: 4,
    shoot: 0,
    armour: 14,
    will: 2,
    health: 16,
    notes: 'Large, Two-Handed Weapon, Potentially Two-Headed',
    specialRules: [
      'Large',
      'Two-Headed (roll d20 on placement): figures fighting against a two-headed troll count as having one fewer supporting figure in the combat than they do.',
    ],
  ),
  CreatureDefinition(
    key: 'vulture',
    name: 'Vulture',
    description:
        'These large scavengers are often used as spies by the Shadow Deep. Rangers are ordered to shoot these birds down on sight if possible.',
    xpValue: 3,
    move: 6,
    fight: 0,
    shoot: 0,
    armour: 14,
    will: 0,
    health: 4,
    notes: 'Animal, Flying',
  ),
  CreatureDefinition(
    key: 'wolf',
    name: 'Wolf',
    description:
        'Somewhere in the darkness of the evil realm, wolves are bred in great numbers, and trained to act as scouts, moving ahead of the forces of the Shadow Deep.',
    xpValue: 2,
    move: 8,
    fight: 1,
    shoot: 0,
    armour: 10,
    will: 0,
    health: 6,
    notes: 'Animal',
  ),
  CreatureDefinition(
    key: 'zombie',
    name: 'Zombie',
    description:
        'The evil within the Shadow Deep delights in using the bodies of the dead to strike terror into the living. Vile necromancers, strange alchemy, and even certain poisons are used to turn people into mindless zombies.',
    xpValue: 2,
    move: 4,
    fight: 0,
    shoot: 0,
    armour: 12,
    will: 0,
    health: 6,
    notes: 'Undead',
  ),
];

CreatureDefinition? getCreature(String key) {
  for (final c in creatures) {
    if (c.key == key) return c;
  }
  return null;
}

List<CreatureDefinition> searchCreatures(String query) {
  if (query.isEmpty) return creatures;
  final lower = query.toLowerCase();
  return creatures.where((c) {
    return c.name.toLowerCase().contains(lower) ||
        c.notes.toLowerCase().contains(lower) ||
        c.key.contains(lower);
  }).toList();
}
