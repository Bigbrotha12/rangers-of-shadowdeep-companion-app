enum HeroicAbilityType {
  heroicAbility,
  spell,
}

class HeroicAbility {
  const HeroicAbility({
    required this.key,
    required this.name,
    required this.description,
    required this.whenToUse,
  });

  final String key;
  final String name;
  final String description;
  final String whenToUse;
}

const List<HeroicAbility> heroicAbilities = [
  HeroicAbility(
    key: 'blend_into_shadows',
    name: 'Blend Into the Shadows',
    description: 'If an evil figure is about to move into combat with the ranger, determine its action as though the ranger were not on the table.',
    whenToUse: 'When an evil figure is about to move into combat with the ranger.',
  ),
  HeroicAbility(
    key: 'dash',
    name: 'Dash',
    description: 'For the rest of the turn, the ranger receives +2 Move. Alternatively, the ranger may use a move action to leap up to his Move distance in any direction, including vertically.',
    whenToUse: 'When the ranger is activated.',
  ),
  HeroicAbility(
    key: 'deadly_shot',
    name: 'Deadly Shot',
    description: 'If the ranger has rolled a natural 18 or 19 during a shooting action, treat this roll as a Critical Hit.',
    whenToUse: 'After rolling a natural 18 or 19 during a shooting action.',
  ),
  HeroicAbility(
    key: 'deadly_strike',
    name: 'Deadly Strike',
    description: 'If the ranger has rolled a natural 18 or 19 during a fight, treat this roll as a Critical Hit.',
    whenToUse: 'After rolling a natural 18 or 19 during a fight.',
  ),
  HeroicAbility(
    key: 'distraction',
    name: 'Distraction',
    description: 'The player may move the creature anywhere he wishes following the standard rules for movement, provided this move does not cause the creature direct harm or force it to make Swimming Rolls.',
    whenToUse: 'Whenever an evil creature is called upon to make a move towards the Target Point.',
  ),
  HeroicAbility(
    key: 'dive_for_cover',
    name: 'Dive for Cover',
    description: 'The ranger may add +10 to his Fight Roll when rolling against a shooting attack. Must declare before rolling.',
    whenToUse: 'When targeted by a shooting attack. Must be declared before rolling.',
  ),
  HeroicAbility(
    key: 'evade',
    name: 'Evade',
    description: 'The ranger may make a free 1" move to leave the combat. No figure may force combat during this move. After this move, the ranger completes his activation as normal.',
    whenToUse: 'When the ranger activates while in combat.',
  ),
  HeroicAbility(
    key: 'focus',
    name: 'Focus',
    description: 'The ranger may add +8 to any one Skill Roll. Must declare before rolling.',
    whenToUse: 'Before making any Skill Roll.',
  ),
  HeroicAbility(
    key: 'frenzied_attack',
    name: 'Frenzied Attack',
    description: 'The ranger may add +5 to one Fight Roll. Must declare before rolling.',
    whenToUse: 'Before making a Fight Roll.',
  ),
  HeroicAbility(
    key: 'halt_undead',
    name: 'Halt Undead',
    description: 'All undead creatures within 10" and line of sight must make a Will Roll (TN20). If they fail, they lose their next activation.',
    whenToUse: 'During the ranger\'s activation.',
  ),
  HeroicAbility(
    key: 'hand_of_fate',
    name: 'Hand of Fate',
    description: 'The ranger may re-roll one die.',
    whenToUse: 'Any time a die roll is made.',
  ),
  HeroicAbility(
    key: 'inner_strength',
    name: 'Inner Strength',
    description: 'The ranger may add +5 to one Will Roll. This ability can be used after the roll has been made.',
    whenToUse: 'After making a Will Roll.',
  ),
  HeroicAbility(
    key: 'parry',
    name: 'Parry',
    description: 'The ranger may add +10 to his roll. If he wins the combat, however, he does no damage. He may step back or push his opponent back as normal.',
    whenToUse: 'After both figures have made their Fight Rolls in hand-to-hand combat.',
  ),
  HeroicAbility(
    key: 'powerful_blow',
    name: 'Powerful Blow',
    description: 'The hero may add +3 damage to any hand-to-hand attack that has already dealt at least 1 point of damage.',
    whenToUse: 'After winning a hand-to-hand combat that dealt at least 1 damage.',
  ),
  HeroicAbility(
    key: 'roll_with_the_punch',
    name: 'Roll With the Punch',
    description: 'Halve the amount of damage taken by the ranger, rounding up.',
    whenToUse: 'If the ranger loses a fight in hand-to-hand combat.',
  ),
  HeroicAbility(
    key: 'shove',
    name: 'Shove',
    description: 'If the ranger wins in hand-to-hand combat, he may choose to push his opponent back up to 4" instead of the normal 1".',
    whenToUse: 'After winning hand-to-hand combat.',
  ),
  HeroicAbility(
    key: 'steady_aim',
    name: 'Steady Aim',
    description: 'The hero may add +5 Shoot for one Shooting Roll. Must be declared before the roll is made.',
    whenToUse: 'Before making a Shooting Roll.',
  ),
];
