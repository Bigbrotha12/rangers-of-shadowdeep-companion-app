import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/constants/companion_types.dart';
import '../../../core/widgets/placeholder_image.dart';
import '../view_models/recruitment_provider.dart';

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
  int _leadershipBonus = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recruitmentProvider(widget.rangerId).notifier)
        ..setBaseRecruitmentPoints(widget.baseRecruitmentPoints)
        ..setPlayerCount(_playerCount)
        ..setLeadershipBonus(_leadershipBonus);
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
                    if (mounted) {
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
            leadershipBonus: _leadershipBonus,
            onPlayerCountChanged: (count) {
              setState(() => _playerCount = count);
              ref.read(recruitmentProvider(widget.rangerId).notifier)
                  .setPlayerCount(count);
            },
            onLeadershipChanged: (bonus) {
              setState(() => _leadershipBonus = bonus);
              ref.read(recruitmentProvider(widget.rangerId).notifier)
                  .setLeadershipBonus(bonus);
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
    required this.leadershipBonus,
    required this.onPlayerCountChanged,
    required this.onLeadershipChanged,
  });

  final RecruitmentState state;
  final int playerCount;
  final int leadershipBonus;
  final ValueChanged<int> onPlayerCountChanged;
  final ValueChanged<int> onLeadershipChanged;

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
                  value: playerCount,
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
                child: DropdownButtonFormField<int>(
                  value: leadershipBonus,
                  decoration: const InputDecoration(
                    labelText: 'Leadership Bonus',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: List.generate(11, (i) => DropdownMenuItem(
                    value: i,
                    child: Text('+$i'),
                  )),
                  onChanged: (value) {
                    if (value != null) onLeadershipChanged(value);
                  },
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
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: state.currentCompanions.length,
        itemBuilder: (context, index) {
          final companion = state.currentCompanions[index];
          return Card(
            margin: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 100,
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
                    'RP: ${companion.rpCost}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
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
          child: ListTile(
            leading: PlaceholderImage(
              assetPath: 'assets/images/companions/${type.key}.png',
              category: 'companion',
              width: 40,
              height: 40,
              borderRadius: 8,
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
        );
      },
    );
  }
}
