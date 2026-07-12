class Spell {
  const Spell({
    required this.key,
    required this.name,
    required this.description,
    required this.targetType,
    this.willRollTn,
  });

  final String key;
  final String name;
  final String description;
  final String targetType; // 'area', 'single_figure', 'self', 'weapon', 'terrain'
  final int? willRollTn;
}

const List<Spell> spells = [
  Spell(
    key: 'burning_light',
    name: 'Burning Light',
    description: 'Make a +3 attack against all undead creatures within 8" and line of sight of the caster.',
    targetType: 'area',
  ),
  Spell(
    key: 'burning_mark',
    name: 'Burning Mark',
    description: 'Place a glowing rune anywhere within 6". As soon as any evil creature moves within 2" of this rune, it explodes. All evil creatures within 2" of the rune suffer a +5 magic shooting attack.',
    targetType: 'terrain',
  ),
  Spell(
    key: 'enchanted_steel',
    name: 'Enchanted Steel',
    description: 'The caster imbues one melee weapon with magic power. For the rest of the scenario, the weapon counts as a magic weapon with +1 Fight.',
    targetType: 'weapon',
  ),
  Spell(
    key: 'heal',
    name: 'Heal',
    description: 'This spell may target any figure within 6" including the caster. The target figure regains up to 5 points of lost Health.',
    targetType: 'single_figure',
  ),
  Spell(
    key: 'hold_creature',
    name: 'Hold Creature',
    description: 'The target creature must make an immediate Will Roll (TN16). If it fails, it may not force combat for the remainder of the turn, and it loses its next activation. This spell has no effect on large creatures or undead.',
    targetType: 'single_figure',
    willRollTn: 16,
  ),
  Spell(
    key: 'magic_bolt',
    name: 'Magic Bolt',
    description: 'The caster may make a +5 magic shooting attack against one figure within line of sight. This attack ignores penalties for cover and intervening terrain.',
    targetType: 'single_figure',
  ),
  Spell(
    key: 'shield_of_light',
    name: 'Shield of Light',
    description: 'This spell may be cast on any figure within 8" and line of sight. All shooting attacks against this figure are at -3 for the rest of the game.',
    targetType: 'single_figure',
  ),
  Spell(
    key: 'smoke',
    name: 'Smoke',
    description: 'The caster may place a thick cloud of smoke, 3" in diameter, anywhere within 3". The smoke blocks all line of sight but does not inhibit movement.',
    targetType: 'terrain',
  ),
  Spell(
    key: 'strong_heart',
    name: 'Strong Heart',
    description: 'This spell may be cast against any figure within 8" and line of sight. The next time this figure must make a Will Roll it does so with a +5 modifier. The time after that, it receives +4, and so on, down to +0 when the spell\'s effect ends.',
    targetType: 'single_figure',
  ),
  Spell(
    key: 'translate',
    name: 'Translate',
    description: 'A ranger may cast this spell in place of making any Read Runes Skill Roll. The ranger automatically passes the Skill Roll with the highest result possible.',
    targetType: 'self',
  ),
];
