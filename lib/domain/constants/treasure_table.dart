class TreasureEntry {
  const TreasureEntry({
    required this.minRoll,
    required this.maxRoll,
    required this.name,
    required this.category,
  });

  final int minRoll;
  final int maxRoll;
  final String name;
  final String category; // 'gold', 'herb_potion', 'weapon_armour', 'magic_item'
}

// Main Treasure Table (d20)
const List<TreasureEntry> treasureTable = [
  TreasureEntry(minRoll: 1, maxRoll: 6, name: 'Gold and Jewels', category: 'gold'),
  TreasureEntry(minRoll: 7, maxRoll: 12, name: 'Herb or Potion', category: 'herb_potion'),
  TreasureEntry(minRoll: 13, maxRoll: 16, name: 'Weapon or Armour', category: 'weapon_armour'),
  TreasureEntry(minRoll: 17, maxRoll: 20, name: 'Magic Item', category: 'magic_item'),
];

// Herbs and Potions Table (d20)
const List<TreasureEntry> herbsPotionsTable = [
  TreasureEntry(minRoll: 1, maxRoll: 1, name: 'Dremlocke Weed', category: 'herb_potion'),
  TreasureEntry(minRoll: 2, maxRoll: 2, name: 'Farlight Leaf', category: 'herb_potion'),
  TreasureEntry(minRoll: 3, maxRoll: 3, name: 'Fireheart Green', category: 'herb_potion'),
  TreasureEntry(minRoll: 4, maxRoll: 4, name: 'Fury Leaves', category: 'herb_potion'),
  TreasureEntry(minRoll: 5, maxRoll: 5, name: 'Ironbark Powder', category: 'herb_potion'),
  TreasureEntry(minRoll: 6, maxRoll: 6, name: 'Nightnock', category: 'herb_potion'),
  TreasureEntry(minRoll: 7, maxRoll: 7, name: 'Quickbeam Root', category: 'herb_potion'),
  TreasureEntry(minRoll: 8, maxRoll: 8, name: 'Haikwheat', category: 'herb_potion'),
  TreasureEntry(minRoll: 9, maxRoll: 9, name: 'Silverhair', category: 'herb_potion'),
  TreasureEntry(minRoll: 10, maxRoll: 10, name: 'Anthalas', category: 'herb_potion'),
  TreasureEntry(minRoll: 11, maxRoll: 11, name: 'Potion of Healing', category: 'herb_potion'),
  TreasureEntry(minRoll: 12, maxRoll: 12, name: 'Potion of Strength', category: 'herb_potion'),
  TreasureEntry(minRoll: 13, maxRoll: 13, name: 'Potion of Toughness', category: 'herb_potion'),
  TreasureEntry(minRoll: 14, maxRoll: 14, name: 'Philtre of Fairy Dust', category: 'herb_potion'),
  TreasureEntry(minRoll: 15, maxRoll: 15, name: 'Explosive Cocktail', category: 'herb_potion'),
  TreasureEntry(minRoll: 16, maxRoll: 16, name: 'Cordial of Spellfire', category: 'herb_potion'),
  TreasureEntry(minRoll: 17, maxRoll: 17, name: 'Potion of Wraithwalk', category: 'herb_potion'),
  TreasureEntry(minRoll: 18, maxRoll: 18, name: 'Potion of Slow Fall', category: 'herb_potion'),
  TreasureEntry(minRoll: 19, maxRoll: 19, name: 'Potion of Heroism', category: 'herb_potion'),
  TreasureEntry(minRoll: 20, maxRoll: 20, name: 'Potion of Restoration', category: 'herb_potion'),
];

// Weapons and Armour Table (d20)
const List<TreasureEntry> weaponsArmourTable = [
  TreasureEntry(minRoll: 1, maxRoll: 1, name: 'Hand Weapon, Magic (5)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 2, maxRoll: 2, name: 'Two-Handed Weapon, Magic (5)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 3, maxRoll: 3, name: 'Bow, Magic (5)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 4, maxRoll: 4, name: 'Crossbow, Magic (5)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 5, maxRoll: 5, name: 'Staff, Magic (5)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 6, maxRoll: 6, name: 'Hand Weapon, Light', category: 'magic_weapon'),
  TreasureEntry(minRoll: 7, maxRoll: 7, name: 'Two-Handed Weapon, Light', category: 'magic_weapon'),
  TreasureEntry(minRoll: 8, maxRoll: 8, name: 'Dagger, Light', category: 'magic_weapon'),
  TreasureEntry(minRoll: 9, maxRoll: 9, name: 'Throwing Knife, Light', category: 'magic_weapon'),
  TreasureEntry(minRoll: 10, maxRoll: 10, name: 'Shield, Brightness (5)', category: 'magic_armour'),
  TreasureEntry(minRoll: 11, maxRoll: 11, name: 'Light Armour, Brightness (5)', category: 'magic_armour'),
  TreasureEntry(minRoll: 12, maxRoll: 12, name: 'Heavy Armour, Brightness (5)', category: 'magic_armour'),
  TreasureEntry(minRoll: 13, maxRoll: 13, name: 'Hand Weapon, Elemental Strike (3)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 14, maxRoll: 14, name: 'Two-Handed Weapon, Elemental Strike (3)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 15, maxRoll: 15, name: 'Staff, Elemental Strike (3)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 16, maxRoll: 16, name: 'Shield, Blocking (1)', category: 'magic_armour'),
  TreasureEntry(minRoll: 17, maxRoll: 17, name: 'Light Armour, Blocking (1)', category: 'magic_armour'),
  TreasureEntry(minRoll: 18, maxRoll: 18, name: 'Heavy Armour, Blocking (1)', category: 'magic_armour'),
  TreasureEntry(minRoll: 19, maxRoll: 19, name: 'Hand Weapon, Blocking (1)', category: 'magic_weapon'),
  TreasureEntry(minRoll: 20, maxRoll: 20, name: 'Two-Handed Weapon, Blocking (1)', category: 'magic_weapon'),
];

// Magic Items Table (d20)
const List<TreasureEntry> magicItemsTable = [
  TreasureEntry(minRoll: 1, maxRoll: 1, name: 'Gemstone of Spellfire (1)', category: 'magic_item'),
  TreasureEntry(minRoll: 2, maxRoll: 2, name: 'Sunfire Pendant (3)', category: 'magic_item'),
  TreasureEntry(minRoll: 3, maxRoll: 3, name: 'Herb Pouch', category: 'magic_item'),
  TreasureEntry(minRoll: 4, maxRoll: 4, name: 'Book of Lore', category: 'magic_item'),
  TreasureEntry(minRoll: 5, maxRoll: 5, name: 'Enchanted Lockpicks (5)', category: 'magic_item'),
  TreasureEntry(minRoll: 6, maxRoll: 6, name: 'Greyleaf Cloak', category: 'magic_item'),
  TreasureEntry(minRoll: 7, maxRoll: 7, name: 'Gauntlets of Strength (5)', category: 'magic_item'),
  TreasureEntry(minRoll: 8, maxRoll: 8, name: 'Amulet of Leadership', category: 'magic_item'),
  TreasureEntry(minRoll: 9, maxRoll: 9, name: 'Gloves of Climbing (5)', category: 'magic_item'),
  TreasureEntry(minRoll: 10, maxRoll: 10, name: 'Eagle-eye Brooch', category: 'magic_item'),
  TreasureEntry(minRoll: 11, maxRoll: 11, name: 'Ring of Teleportation (1)', category: 'magic_item'),
  TreasureEntry(minRoll: 12, maxRoll: 12, name: 'Boots of Soft Tread (2)', category: 'magic_item'),
  TreasureEntry(minRoll: 13, maxRoll: 13, name: 'Cloak of Invisibility (2)', category: 'magic_item'),
  TreasureEntry(minRoll: 14, maxRoll: 14, name: 'Fishglass (1)', category: 'magic_item'),
  TreasureEntry(minRoll: 15, maxRoll: 15, name: 'Gemstone of Heartlight (1)', category: 'magic_item'),
  TreasureEntry(minRoll: 16, maxRoll: 16, name: 'Spell Ring (1)', category: 'magic_item'),
  TreasureEntry(minRoll: 17, maxRoll: 17, name: 'Tool Kit', category: 'magic_item'),
  TreasureEntry(minRoll: 18, maxRoll: 18, name: 'Spell-shield Pendant (1)', category: 'magic_item'),
  TreasureEntry(minRoll: 19, maxRoll: 19, name: 'Fireball Orb (1)', category: 'magic_item'),
  TreasureEntry(minRoll: 20, maxRoll: 20, name: 'Fate Stone (1)', category: 'magic_item'),
];

/// Look up a treasure entry by d20 roll from a table
TreasureEntry? lookupTreasure(List<TreasureEntry> table, int d20) {
  for (final entry in table) {
    if (d20 >= entry.minRoll && d20 <= entry.maxRoll) {
      return entry;
    }
  }
  return null;
}

/// Resolve a complete treasure roll: main table -> sub-table
/// Returns the final item name and category
({String name, String category}) resolveTreasureRoll(int mainRoll, int subRoll) {
  final mainEntry = lookupTreasure(treasureTable, mainRoll);
  if (mainEntry == null) {
    return (name: 'Unknown', category: 'unknown');
  }

  switch (mainEntry.category) {
    case 'gold':
      return (name: 'Gold and Jewels', category: 'gold');
    case 'herb_potion':
      final subEntry = lookupTreasure(herbsPotionsTable, subRoll);
      return (name: subEntry?.name ?? 'Unknown Herb', category: 'herb_potion');
    case 'weapon_armour':
      final subEntry = lookupTreasure(weaponsArmourTable, subRoll);
      return (name: subEntry?.name ?? 'Unknown Weapon', category: 'weapon_armour');
    case 'magic_item':
      final subEntry = lookupTreasure(magicItemsTable, subRoll);
      return (name: subEntry?.name ?? 'Unknown Item', category: 'magic_item');
    default:
      return (name: 'Unknown', category: 'unknown');
  }
}
