enum StatusEffectCategory { negative, positive, injury }

class StatusEffect {
  final String key;
  final String name;
  final String description;
  final bool isTemporary;
  final StatusEffectCategory category;
  final Map<String, int> statModifiers;
  final String? specialRule;

  const StatusEffect({
    required this.key,
    required this.name,
    required this.description,
    this.isTemporary = true,
    this.category = StatusEffectCategory.negative,
    this.statModifiers = const {},
    this.specialRule,
  });
}

const List<StatusEffect> statusEffects = [
  StatusEffect(
    key: 'poisoned',
    name: 'Poisoned',
    description: 'Max 1 action per activation. Cured by full healing or specific cures. Lasts until end of scenario.',
    isTemporary: true,
    category: StatusEffectCategory.negative,
    specialRule: 'max_one_action',
  ),
  StatusEffect(
    key: 'diseased',
    name: 'Diseased',
    description: '-3 Health next scenario, -1 to all rolls for the scenario. Auto-cured after one scenario.',
    isTemporary: true,
    category: StatusEffectCategory.negative,
    statModifiers: {'move': -1, 'fight': -1, 'shoot': -1, 'armour': -1, 'will': -1},
    specialRule: 'next_scenario_health_minus_3',
  ),
  StatusEffect(
    key: 'hunger_1',
    name: 'Hunger/Thirst (1)',
    description: '-2 Health this mission. Stacks with additional hunger effects.',
    isTemporary: true,
    category: StatusEffectCategory.negative,
    statModifiers: {'health': -2},
  ),
  StatusEffect(
    key: 'hunger_2',
    name: 'Hunger/Thirst (2)',
    description: '-4 Health this mission. Stacks with additional hunger effects.',
    isTemporary: true,
    category: StatusEffectCategory.negative,
    statModifiers: {'health': -4},
  ),
  StatusEffect(
    key: 'hunger_3',
    name: 'Hunger/Thirst (3)',
    description: '-6 Health this mission. Stacks with additional hunger effects.',
    isTemporary: true,
    category: StatusEffectCategory.negative,
    statModifiers: {'health': -6},
  ),
  StatusEffect(
    key: 'exhausted',
    name: 'Exhausted',
    description: '-1 Move, -1 Will until rested.',
    isTemporary: true,
    category: StatusEffectCategory.negative,
    statModifiers: {'move': -1, 'will': -1},
  ),
  StatusEffect(
    key: 'blessed',
    name: 'Blessed',
    description: '+1 Will until end of scenario.',
    isTemporary: true,
    category: StatusEffectCategory.positive,
    statModifiers: {'will': 1},
  ),
  StatusEffect(
    key: 'cursed',
    name: 'Cursed',
    description: 'Varies by curse. Consult scenario rules.',
    isTemporary: true,
    category: StatusEffectCategory.negative,
    specialRule: 'varies_by_curse',
  ),
];

StatusEffect? getStatusEffect(String key) =>
    statusEffects.where((e) => e.key == key).firstOrNull;
