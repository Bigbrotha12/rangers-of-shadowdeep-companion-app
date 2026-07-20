import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/ui/core/widgets/placeholder_image.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/recruitment_provider.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RecruitCompanionsView extends ConsumerStatefulWidget {
  const RecruitCompanionsView({
    required this.rangerId,
    required this.baseRecruitmentPoints,
    super.key,
  });

  final int rangerId;
  final int baseRecruitmentPoints;

  @override
  ConsumerState<RecruitCompanionsView> createState() => _RecruitCompanionsViewState();
}

class _RecruitCompanionsViewState extends ConsumerState<RecruitCompanionsView> {
  int _playerCount = 1;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recruitmentProvider(widget.rangerId).notifier)
        ..setBaseRecruitmentPoints(widget.baseRecruitmentPoints)
        ..setPlayerCount(_playerCount);

      // Fetch leadership skill from ranger detail
      ref.read(rangerDetailProvider(widget.rangerId).future).then((detail) {
        if (detail != null && mounted) {
          final leadershipValue = detail.skillBonuses
              .where((s) => s.skillKey == 'leadership')
              .fold(0, (sum, s) => sum + s.value);
          ref.read(recruitmentProvider(widget.rangerId).notifier)
              .setLeadershipBonus(leadershipValue);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final recruitmentState = ref.watch(recruitmentProvider(widget.rangerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recruit Companions'),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() => _isSaving = true);
                    await ref.read(recruitmentProvider(widget.rangerId).notifier).saveCompanions();
                    ref.invalidate(rangerDetailProvider(widget.rangerId));
                    if (context.mounted) {
                      context.pop();
                    }
                  },
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          _RecruitmentHeader(
            state: recruitmentState,
            playerCount: _playerCount,
            onPlayerCountChanged: (count) {
              setState(() => _playerCount = count);
              ref.read(recruitmentProvider(widget.rangerId).notifier)
                  .setPlayerCount(count);
            },
          ),
          const Divider(),
          Expanded(
            child: _RecruitmentBody(
              rangerId: widget.rangerId,
              state: recruitmentState,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecruitmentHeader extends StatelessWidget {
  const _RecruitmentHeader({
    required this.state,
    required this.playerCount,
    required this.onPlayerCountChanged,
  });

  final RecruitmentState state;
  final int playerCount;
  final ValueChanged<int> onPlayerCountChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total RP',
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      '${state.totalRecruitmentPoints}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available RP',
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      '${state.availableRecruitmentPoints}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: state.availableRecruitmentPoints > 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Companions',
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      '${state.currentCompanions.length}/${state.maxCompanions}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: playerCount,
                  decoration: const InputDecoration(
                    labelText: 'Players',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: List.generate(4, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1} Player${i == 0 ? '' : 's'}'),
                  )),
                  onChanged: (value) {
                    if (value != null) onPlayerCountChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Leadership Bonus',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '+${state.leadershipBonus}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecruitmentBody extends StatelessWidget {
  const _RecruitmentBody({
    required this.rangerId,
    required this.state,
  });

  final int rangerId;
  final RecruitmentState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.currentCompanions.isNotEmpty) ...[
          _CurrentCompanionsList(
            rangerId: rangerId,
            state: state,
          ),
          const Divider(),
        ],
        Expanded(
          child: _AvailableCompanionsList(
            rangerId: rangerId,
            state: state,
          ),
        ),
      ],
    );
  }
}

class _CurrentCompanionsList extends ConsumerWidget {
  const _CurrentCompanionsList({
    required this.rangerId,
    required this.state,
  });

  final int rangerId;
  final RecruitmentState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 136,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: state.currentCompanions.length,
        itemBuilder: (context, index) {
          final companion = state.currentCompanions[index];
          final isConjuror = companion.key == 'conjuror';
          return Card(
            margin: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: isConjuror ? 140 : 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlaceholderImage(
                    assetPath: 'assets/images/companions/${companion.key}.png',
                    category: 'companion',
                    width: 32,
                    height: 32,
                    borderRadius: 0,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    companion.name,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'RP: ${companion.effectiveRpCost}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: companion.hasPurchasedThirdSpell
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.primary,
                    ),
                  ),
                  if (isConjuror)
                    TextButton.icon(
                      icon: Icon(
                        companion.hasPurchasedThirdSpell
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 14,
                      ),
                      label: Text(
                        '3rd Spell',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: companion.hasPurchasedThirdSpell
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onPressed: () {
                        ref.read(recruitmentProvider(rangerId).notifier)
                            .toggleThirdSpell(index);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () {
                      ref.read(recruitmentProvider(rangerId).notifier)
                          .removeCompanion(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AvailableCompanionsList extends ConsumerWidget {
  const _AvailableCompanionsList({
    required this.rangerId,
    required this.state,
  });

  final int rangerId;
  final RecruitmentState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: companionTypes.length,
      itemBuilder: (context, index) {
        final type = companionTypes[index];
        final canRecruit = state.canRecruit(type);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/reference/companions/${type.key}'),
            child: ListTile(
              leading: PlaceholderImage(
                assetPath: 'assets/images/companions/${type.key}.png',
                category: 'companion',
                width: 40,
                height: 40,
              ),
              title: Text(type.name),
              subtitle: Text(
                type.notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RP ${type.rpCost}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: canRecruit
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: canRecruit
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: canRecruit
                        ? () {
                            ref.read(recruitmentProvider(rangerId).notifier)
                                .recruitCompanion(type);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
