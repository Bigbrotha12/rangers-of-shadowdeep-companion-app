import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart' show companionTypeKeyFromId, getCompanionType;
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_utils.dart';
import 'package:rangers_mobile/ui/core/widgets/placeholder_image.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RangerCompanionsTab extends ConsumerWidget {
  const RangerCompanionsTab({
    required this.rangerId,
    super.key,
  });

  final int rangerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rangerAsync = ref.watch(rangerDetailProvider(rangerId));

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) {
          return const Center(child: Text('Ranger not found'));
        }

        if (ranger.companions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: Spacing.lg),
                Text(
                  'No Companions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Recruit companions to join your company.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                FilledButton.icon(
                  onPressed: () => context.push('/rangers/$rangerId/companions/recruit?brp=${ranger.ranger.baseRecruitmentPoints}'),
                  icon: const Icon(Icons.pets),
                  label: const Text('Recruit Companions'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ranger.companions.length} Companion(s)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push('/rangers/$rangerId/companions/recruit?brp=${ranger.ranger.baseRecruitmentPoints}'),
                    icon: const Icon(Icons.add),
                    label: const Text('Recruit'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                itemCount: ranger.companions.length,
                itemBuilder: (context, index) {
                  final companion = ranger.companions[index];
                  final typeKey = companionTypeKeyFromId(companion.companionTypeId);
                  final type = getCompanionType(typeKey);
                  final customSkills = Map<String, int>.from(
                    const JsonDecoder().convert(companion.customSkills) as Map? ?? {},
                  );
                  final companionEquip = ranger.equipment
                    .where((e) => e.slotIndex != null)
                    .where((e) => e.equipment.equippedBy == companion.id.toString())
                    .toList();
                  final equipMods = computeEquipmentModifiers(companionEquip);
                  int effectiveStat(int base, String key) =>
                      base + (customSkills[key] ?? 0) + (equipMods[key] ?? 0);
                  return Card(
                    margin: const EdgeInsets.only(bottom: Spacing.sm),
                    child: InkWell(
                      onTap: () => context.push('/rangers/$rangerId/companions/${companion.id}'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                PlaceholderImage(
                                  assetPath: 'assets/images/companions/$typeKey.png',
                                  category: 'companion',
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        companion.customName,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'PP: ${companion.progressionPoints}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (type != null)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: ['M', 'F', 'S', 'A', 'W', 'H'].map((l) =>
                                          SizedBox(
                                            width: 24,
                                            child: Text(
                                              l,
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ).toList(),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          effectiveStat(type.move, 'move'),
                                          effectiveStat(type.fight, 'fight'),
                                          effectiveStat(type.shoot, 'shoot'),
                                          effectiveStat(type.armour, 'armour'),
                                          effectiveStat(type.will, 'will'),
                                          effectiveStat(type.health, 'health'),
                                        ].map((v) =>
                                          SizedBox(
                                            width: 24,
                                            child: Text(
                                              '$v',
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ).toList(),
                                      ),
                                    ],
                                  ),
                                const SizedBox(width: Spacing.xs),
                                Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
