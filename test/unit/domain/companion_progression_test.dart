import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/companion_progression.dart';

void main() {
  group('progressionRewards', () {
    test('has 9 reward thresholds', () {
      expect(progressionRewards.length, 9);
    });

    test('thresholds are at 5, 10, 15, 20, 25, 30, 35, 40, 50', () {
      final thresholds = progressionRewards.map((r) => r.threshold).toList();
      expect(thresholds, [5, 10, 15, 20, 25, 30, 35, 40, 50]);
    });

    test('reward types are correct', () {
      expect(progressionRewards[0].rewardType, 'health');
      expect(progressionRewards[1].rewardType, 'fight_or_shoot');
      expect(progressionRewards[2].rewardType, 'skill');
      expect(progressionRewards[3].rewardType, 'will');
      expect(progressionRewards[4].rewardType, 'heroic_ability');
      expect(progressionRewards[5].rewardType, 'health');
      expect(progressionRewards[6].rewardType, 'skill');
      expect(progressionRewards[7].rewardType, 'will');
      expect(progressionRewards[8].rewardType, 'heroic_ability');
    });

    test('maxProgressionPoints is 50', () {
      expect(maxProgressionPoints, 50);
    });

    test('fight_or_shoot reward has choices', () {
      expect(progressionRewards[1].choices, ['fight', 'shoot']);
    });
  });

  group('getNextProgressionReward', () {
    test('returns first threshold reward when none claimed', () {
      final reward = getNextProgressionReward(5, {});
      expect(reward, isNotNull);
      expect(reward!.threshold, 5);
      expect(reward.rewardType, 'health');
    });

    test('returns next unclaimed threshold', () {
      final reward = getNextProgressionReward(20, {5, 10, 15});
      expect(reward!.threshold, 20);
    });

    test('returns null when no thresholds reached', () {
      expect(getNextProgressionReward(4, {}), isNull);
    });

    test('returns null when all reached thresholds are claimed', () {
      expect(getNextProgressionReward(5, {5}), isNull);
    });

    test('returns next when PP exceeds multiple thresholds', () {
      final reward = getNextProgressionReward(15, {5});
      expect(reward!.threshold, 10);
    });

    test('returns null when PP at 50 and all claimed', () {
      expect(
        getNextProgressionReward(50, {5, 10, 15, 20, 25, 30, 35, 40, 50}),
        isNull,
      );
    });
  });

  group('getUnclaimedRewards', () {
    test('returns all thresholds up to PP not yet claimed', () {
      final rewards = getUnclaimedRewards(15, {5});
      final thresholds = rewards.map((r) => r.threshold).toList();
      expect(thresholds, [10, 15]);
    });

    test('returns empty when PP below first threshold', () {
      expect(getUnclaimedRewards(4, {}), isEmpty);
    });

    test('returns all 9 rewards when PP at 50 and none claimed', () {
      expect(getUnclaimedRewards(50, {}).length, 9);
    });

    test('returns empty when all thresholds claimed', () {
      expect(
        getUnclaimedRewards(50, {5, 10, 15, 20, 25, 30, 35, 40, 50}),
        isEmpty,
      );
    });

    test('excludes claimed thresholds', () {
      final rewards = getUnclaimedRewards(25, {5, 10, 15, 20});
      final thresholds = rewards.map((r) => r.threshold).toList();
      expect(thresholds, [25]);
    });
  });
}
