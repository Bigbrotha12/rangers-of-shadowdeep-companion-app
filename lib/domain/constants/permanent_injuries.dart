class PermanentInjury {
  const PermanentInjury({
    required this.key,
    required this.name,
    required this.description,
    required this.effect,
    this.affectedStat,
    this.penalty,
    this.maxTimesReceived = 2,
  });

  final String key;
  final String name;
  final String description;
  final String effect;
  final String? affectedStat;
  final int? penalty;
  final int maxTimesReceived;
}

const List<PermanentInjury> permanentInjuries = [
  PermanentInjury(
    key: 'lost_toes',
    name: 'Lost Toes',
    description: 'The figure has lost one or more toes. It suffers a permanent -0.5 penalty to its Move. This injury can be received twice, with a cumulative effect of -1 Move.',
    effect: 'Permanent -0.5 Move per occurrence (max 2)',
    affectedStat: 'move',
    penalty: -1,
  ),
  PermanentInjury(
    key: 'smashed_leg',
    name: 'Smashed Leg',
    description: 'The figure suffers permanent bone or muscle damage in its leg. It suffers a -1 penalty to its Move. This injury can be received twice, with a cumulative effect of -2 Move.',
    effect: 'Permanent -1 Move per occurrence (max 2)',
    affectedStat: 'move',
    penalty: -1,
  ),
  PermanentInjury(
    key: 'crushed_arm',
    name: 'Crushed Arm',
    description: 'The figure suffers permanent bone or muscle damage in its arm. It suffers a -1 penalty to its Fight. This injury can be received twice, with a cumulative effect of -2 Fight.',
    effect: 'Permanent -1 Fight per occurrence (max 2)',
    affectedStat: 'fight',
    penalty: -1,
  ),
  PermanentInjury(
    key: 'lost_fingers',
    name: 'Lost Fingers',
    description: 'The figure has lost one or more fingers. It suffers a permanent -1 penalty to its Shoot. This injury can be received twice, with a cumulative effect of -2 Shoot.',
    effect: 'Permanent -1 Shoot per occurrence (max 2)',
    affectedStat: 'shoot',
    penalty: -1,
  ),
  PermanentInjury(
    key: 'never_quite_as_strong',
    name: 'Never Quite as Strong',
    description: 'Due to internal injuries, the figure never quite returns to full health. It starts every game at -1 Health. This injury can be received twice, with a cumulative effect of -2 Health.',
    effect: 'Start every game at -1 Health per occurrence (max 2)',
    affectedStat: 'health',
    penalty: -1,
  ),
  PermanentInjury(
    key: 'psychological_scars',
    name: 'Psychological Scars',
    description: 'The figure\'s physical injuries heal, but the mental trauma does not. It suffers a -1 to its Will. This injury can be received twice, with a cumulative effect of -2 Will.',
    effect: 'Permanent -1 Will per occurrence (max 2)',
    affectedStat: 'will',
    penalty: -1,
  ),
  PermanentInjury(
    key: 'smashed_jaw',
    name: 'Smashed Jaw',
    description: 'The figure suffers a broken jaw that never quite heals properly. If the figure is a ranger, the player may only activate one companion in the ranger phase, instead of the usual two. Furthermore, the ranger suffers -3 to Leadership Skill Rolls. This injury has no specific penalty for a companion.',
    effect: 'Ranger: max 1 companion activation, -3 Leadership',
    maxTimesReceived: 1,
  ),
  PermanentInjury(
    key: 'lost_eye',
    name: 'Lost Eye',
    description: 'One of the figure\'s eyes has been damaged and rendered useless. It suffers a -1 to its Fight Roll whenever it is the target of a shooting attack. If a figure receives two Lost Eye permanent injuries, it is effectively blind, and unable to continue its adventures.',
    effect: '-1 Fight when targeted by shooting. Two occurrences = blind (retired).',
  ),
];

/// Roll on the Permanent Injury Table (d20)
/// Returns the injury key based on die roll
String rollPermanentInjury(int d20) {
  if (d20 <= 2) return 'lost_toes';
  if (d20 <= 5) return 'smashed_leg';
  if (d20 <= 10) return 'crushed_arm';
  if (d20 <= 12) return 'lost_fingers';
  if (d20 <= 14) return 'never_quite_as_strong';
  if (d20 <= 16) return 'psychological_scars';
  if (d20 <= 18) return 'smashed_jaw';
  return 'lost_eye';
}
