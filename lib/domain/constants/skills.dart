class Skill {
  const Skill({
    required this.key,
    required this.name,
    required this.description,
  });

  final String key;
  final String name;
  final String description;
}

const List<Skill> skills = [
  Skill(
    key: 'acrobatics',
    name: 'Acrobatics',
    description: 'A measure of the ranger\'s ability to control his own body in difficult situations, such as jumping, walking along narrow paths, and swinging from ropes. It does not include climbing, which is a separate Skill.',
  ),
  Skill(
    key: 'ancient_lore',
    name: 'Ancient Lore',
    description: 'Knowledge of myth, legend, and ancient history, including all that is known about the Shadow Deep.',
  ),
  Skill(
    key: 'armoury',
    name: 'Armoury',
    description: 'The study of weaponry, including how to make and repair weapons, how to improvise weapons in the field, and how to identify magic weapons. If a ranger has an Armoury Skill of +4 or more, he is always treated as armed with a dagger, even if unarmed.',
  ),
  Skill(
    key: 'climb',
    name: 'Climb',
    description: 'Measures the ranger\'s ability to climb difficult surfaces.',
  ),
  Skill(
    key: 'leadership',
    name: 'Leadership',
    description: 'The skill of leading others, it also includes diplomacy. A Ranger may add his Leadership Skill to his Total Recruitment Points before each mission.',
  ),
  Skill(
    key: 'navigation',
    name: 'Navigation',
    description: 'Using the natural world to determine direction and location and to keep from getting lost.',
  ),
  Skill(
    key: 'perception',
    name: 'Perception',
    description: 'The general awareness of one\'s surroundings, including noticing small, but important details.',
  ),
  Skill(
    key: 'pick_lock',
    name: 'Pick Lock',
    description: 'Encompasses knowledge of all kinds of lock and locking mechanisms, including doors, chests, and even secret doors.',
  ),
  Skill(
    key: 'read_runes',
    name: 'Read Runes',
    description: 'The knowledge of ancient written languages, including the languages of magic.',
  ),
  Skill(
    key: 'stealth',
    name: 'Stealth',
    description: 'Moving silently to avoid detection and skill in choosing and maintaining hiding places.',
  ),
  Skill(
    key: 'strength',
    name: 'Strength',
    description: 'The training in the application of strength to achieve maximum results, useful for lifting, breaking down doors, and escaping from bonds.',
  ),
  Skill(
    key: 'survival',
    name: 'Survival',
    description: 'Includes foraging for food and herbs, hunting, cooking, basic first-aid, and knowledge of the dangers inherent in specific types of terrain.',
  ),
  Skill(
    key: 'swim',
    name: 'Swim',
    description: 'Movement through water, or any water-like substance.',
  ),
  Skill(
    key: 'track',
    name: 'Track',
    description: 'The ability to read the signs of the land to gain information about those that have preceded them, such as their direction of travel, distance ahead, and if they are wounded or carrying prisoners. Also includes knowledge of how to throw off pursuers.',
  ),
  Skill(
    key: 'traps',
    name: 'Traps',
    description: 'Knowledge of traps, including how to set them and how to disable them.',
  ),
];


