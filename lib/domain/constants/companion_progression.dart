/// Companion progression point thresholds and rewards
class ProgressionReward {
  const ProgressionReward({
    required this.threshold,
    required this.rewardType,
    required this.description,
    this.choices,
  });

  final int threshold;
  final String rewardType; // 'health', 'fight_or_shoot', 'skill', 'will', 'heroic_ability'
  final String description;
  final List<String>? choices;
}

const List<ProgressionReward> progressionRewards = [
  ProgressionReward(
    threshold: 5,
    rewardType: 'health',
    description: '+1 Health',
  ),
  ProgressionReward(
    threshold: 10,
    rewardType: 'fight_or_shoot',
    description: '+1 Fight or +1 Shoot',
    choices: ['fight', 'shoot'],
  ),
  ProgressionReward(
    threshold: 15,
    rewardType: 'skill',
    description: '+4 to one Skill (max +10)',
  ),
  ProgressionReward(
    threshold: 20,
    rewardType: 'will',
    description: '+2 Will',
  ),
  ProgressionReward(
    threshold: 25,
    rewardType: 'heroic_ability',
    description: 'Choose one Heroic Ability',
  ),
  ProgressionReward(
    threshold: 30,
    rewardType: 'health',
    description: '+1 Health',
  ),
  ProgressionReward(
    threshold: 35,
    rewardType: 'skill',
    description: '+4 to one Skill (max +10)',
  ),
  ProgressionReward(
    threshold: 40,
    rewardType: 'will',
    description: '+2 Will',
  ),
  ProgressionReward(
    threshold: 50,
    rewardType: 'heroic_ability',
    description: 'Choose one Heroic Ability',
  ),
];

/// Maximum progression points a companion can earn
const int maxProgressionPoints = 50;

/// Get the next unclaimed reward for a companion's current PP
ProgressionReward? getNextProgressionReward(int currentPP, Set<int> claimedThresholds) {
  for (final reward in progressionRewards) {
    if (currentPP >= reward.threshold && !claimedThresholds.contains(reward.threshold)) {
      return reward;
    }
  }
  return null;
}

/// Check if a companion has reached a new threshold
bool hasNewThreshold(int currentPP, Set<int> claimedThresholds) {
  return getNextProgressionReward(currentPP, claimedThresholds) != null;
}

/// Get all thresholds that have been reached but not yet claimed
List<ProgressionReward> getUnclaimedRewards(int currentPP, Set<int> claimedThresholds) {
  final unclaimed = <ProgressionReward>[];
  for (final reward in progressionRewards) {
    if (currentPP >= reward.threshold && !claimedThresholds.contains(reward.threshold)) {
      unclaimed.add(reward);
    }
  }
  return unclaimed;
}
