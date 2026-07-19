import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';

class AssignSkillBonusView extends ConsumerStatefulWidget {
  const AssignSkillBonusView({
    required this.rangerId,
    required this.companionId,
    super.key,
  });

  final int rangerId;
  final int companionId;

  @override
  ConsumerState<AssignSkillBonusView> createState() => _AssignSkillBonusViewState();
}

class _AssignSkillBonusViewState extends ConsumerState<AssignSkillBonusView> {
  String? _selectedSkillKey;

  @override
  Widget build(BuildContext context) {
    final companion = ref.watch(companionProvider(widget.companionId));
    final theme = Theme.of(context);

    if (companion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assign Skill Bonus')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final type = companion.type;
    if (type == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assign Skill Bonus')),
        body: const Center(child: Text('Unknown companion type')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign +3 Skill Bonus'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select a skill to assign +3 bonus to ${companion.customName}. This can be assigned to a skill the companion already possesses or any new skill.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                final currentValue = type.baseSkills[skill.key] ?? 0;
                final customValue = companion.customSkills[skill.key] ?? 0;
                final totalValue = currentValue + customValue;
                final isSelected = _selectedSkillKey == skill.key;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected ? theme.colorScheme.primaryContainer : null,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedSkillKey = skill.key;
                      });
                    },
                    title: Text(skill.name),
                    subtitle: Text(
                      skill.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: totalValue > 0
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            totalValue > 0 ? '+$totalValue' : '+0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _selectedSkillKey != null
                ? () async {
                    if (_selectedSkillKey != null && !companion.hasUsedRecruitmentBonus) {
                      final currentCustomValue = companion.customSkills[_selectedSkillKey!] ?? 0;
                      await ref.read(companionProvider(widget.companionId).notifier)
                          .updateCustomSkill(_selectedSkillKey!, currentCustomValue + 3);
                      await ref.read(companionProvider(widget.companionId).notifier)
                          .markRecruitmentBonusUsed();
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  }
                : null,
            child: const Text('Assign +3 Bonus'),
          ),
        ),
      ),
    );
  }
}
