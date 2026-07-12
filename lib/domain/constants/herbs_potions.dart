class HerbPotion {
  const HerbPotion({
    required this.key,
    required this.name,
    required this.description,
    required this.effects,
  });

  final String key;
  final String name;
  final String description;
  final String effects;
}

const List<HerbPotion> herbsAndPotions = [
  HerbPotion(
    key: 'dremlocke_weed',
    name: 'Dremlocke Weed',
    description: 'The figure receives +5 on all Will Rolls.',
    effects: '{"will_bonus":5}',
  ),
  HerbPotion(
    key: 'farlight_leaf',
    name: 'Farlight Leaf',
    description: 'The user receives +1 Shoot, but -1 Fight and -1 Will.',
    effects: '{"shoot_bonus":1,"fight_penalty":-1,"will_penalty":-1}',
  ),
  HerbPotion(
    key: 'fireheart_green',
    name: 'Fireheart Green',
    description: 'A figure that takes this herb receives +1 action on its next activation. No figure may have more than three actions per activation.',
    effects: '{"extra_action":1}',
  ),
  HerbPotion(
    key: 'fury_leaves',
    name: 'Fury Leaves',
    description: 'The user does an additional 1 point of damage whenever he wins a combat. Additionally, he suffers -2 Will.',
    effects: '{"damage_bonus":1,"will_penalty":-2}',
  ),
  HerbPotion(
    key: 'ironbark_powder',
    name: 'Ironbark Powder',
    description: 'The user receives +1 Armour, but -2 Will.',
    effects: '{"armour_bonus":1,"will_penalty":-2}',
  ),
  HerbPotion(
    key: 'nightnock',
    name: 'Nightnock',
    description: 'A figure suffering from disease may take this herb before a scenario. The disease is cured, and the figure suffers no penalties for it in the next scenario.',
    effects: '{"cure_disease":true}',
  ),
  HerbPotion(
    key: 'quickbeam_root',
    name: 'Quickbeam Root',
    description: 'A figure that drinks this potion receives +2 Move, but -2 Will.',
    effects: '{"move_bonus":2,"will_penalty":-2}',
  ),
  HerbPotion(
    key: 'haikwheat',
    name: 'Haikwheat',
    description: 'The user gains 2 temporary points of Health. This can take the user above his normal starting amount, but only for the length of the scenario. He also suffers -1 Will.',
    effects: '{"temp_health":2,"will_penalty":-1}',
  ),
  HerbPotion(
    key: 'silverhair',
    name: 'Silverhair',
    description: 'When burned, this herb gives off a smell that is repugnant to gnolls. All gnolls suffer -1 Fight when in combat with the user.',
    effects: '{"gnoll_fight_penalty":-1}',
  ),
  HerbPotion(
    key: 'anthalas',
    name: 'Anthalas',
    description: 'If any figure is carrying this herb, it can be used by either the ranger or any one of his companions after a game. That figure gains +1 on its Survival Roll after the scenario.',
    effects: '{"survival_bonus":1,"post_game":true}',
  ),
  HerbPotion(
    key: 'potion_of_healing',
    name: 'Potion of Healing',
    description: 'This potion restores 5 points of Health and removes any effects of poison. This cannot take a figure above its starting Health level.',
    effects: '{"heal":5,"cure_poison":true}',
  ),
  HerbPotion(
    key: 'potion_of_strength',
    name: 'Potion of Strength',
    description: 'A figure that drinks this potion receives +1 Fight.',
    effects: '{"fight_bonus":1}',
  ),
  HerbPotion(
    key: 'potion_of_toughness',
    name: 'Potion of Toughness',
    description: 'A figure that drinks this potion receives +1 Armour.',
    effects: '{"armour_bonus":1}',
  ),
  HerbPotion(
    key: 'philtre_of_fairy_dust',
    name: 'Philtre of Fairy Dust',
    description: 'If this dust is sprinkled over a weapon, that weapon counts as magic. It may be sprinkled over an arrow or crossbow bolt, though these will be one-use items.',
    effects: '{"make_magic_weapon":true}',
  ),
  HerbPotion(
    key: 'explosive_cocktail',
    name: 'Explosive Cocktail',
    description: 'A figure may spend an action to throw this potion to any point up to 8" away and in line of sight. Every figure within 2" of that point suffers an immediate +3 shooting attack.',
    effects: '{"throw_damage":3,"range":8,"radius":2}',
  ),
  HerbPotion(
    key: 'cordial_of_spellfire',
    name: 'Cordial of Spellfire',
    description: 'A figure that drinks this potion regains the use of any one spell that it has already used in the scenario.',
    effects: '{"re_cast_spell":true}',
  ),
  HerbPotion(
    key: 'potion_of_wraithwalk',
    name: 'Potion of Wraithwalk',
    description: 'A figure that drinks this potion can move through terrain as though it were not there. This ability lasts for one turn after the potion is drunk.',
    effects: '{"ignore_terrain":true,"duration":"1_turn"}',
  ),
  HerbPotion(
    key: 'potion_of_slow_fall',
    name: 'Potion of Slow Fall',
    description: 'A figure that drinks this potion can fall any distance and take no damage. This ability lasts for one turn after the potion is drunk.',
    effects: '{"no_fall_damage":true,"duration":"1_turn"}',
  ),
  HerbPotion(
    key: 'potion_of_heroism',
    name: 'Potion of Heroism',
    description: 'A figure that drinks this potion regains the use of any one Heroic Ability that it has already used in the scenario.',
    effects: '{"re_use_ability":true}',
  ),
  HerbPotion(
    key: 'potion_of_restoration',
    name: 'Potion of Restoration',
    description: 'A figure that drinks this potion is immediately restored to its starting Health and is cured of any poison, disease, or temporary Stat reductions. This potion may also be used after a game – in this case, it cures a figure of a single permanent injury of the player\'s choice.',
    effects: '{"full_heal":true,"cure_poison":true,"cure_disease":true,"cure_temp_stat":true,"cure_permanent_injury":true}',
  ),
];
