import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/repositories/companion_repository_provider.dart';
import '../../../../domain/constants/companion_types.dart';
import '../../../../domain/constants/skills.dart';
import '../../../core/widgets/stat_display.dart';
import '../../../core/widgets/placeholder_image.dart';
import '../view_models/companion_provider.dart';

class CompanionDetailView extends ConsumerWidget {
  const CompanionDetailView({
    required this.rangerId,
    required this.companionId,
    super.key,
  });

  final int rangerId;
  final int companionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companion = ref.watch(companionProvider(companionId));

    if (companion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Companion')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final type = companion.type;
    if (type == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Companion')),
        body: const Center(child: Text('Unknown companion type')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(companion.customName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  _showRenameDialog(context, ref, companion);
                  break;
                case 'assign_skill':
                  context.push('/rangers/$rangerId/companions/$companionId/assign-skill');
                  break;
                case 'progression':
                  context.push('/rangers/$rangerId/companions/$companionId/progression');
                  break;
                case 'remove':
                  _showRemoveDialog(context, ref, companion);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Rename'),
                ),
              ),
              const PopupMenuItem(
                value: 'assign_skill',
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Assign +3 Skill Bonus'),
                ),
              ),
              const PopupMenuItem(
                value: 'progression',
                child: ListTile(
                  leading: Icon(Icons.trending_up),
                  title: Text('View Progression'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            _CompanionHeader(companion: companion, type: type),
            const TabBar(
              tabs: [
                Tab(text: 'Stats'),
                Tab(text: 'Skills'),
                Tab(text: 'Injuries'),
                Tab(text: 'Info'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _StatsTab(companion: companion, type: type),
                  _SkillsTab(companion: companion, type: type),
                  _InjuriesTab(companion: companion),
                  _InfoTab(companion: companion, type: type),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, CompanionData companion) {
    final controller = TextEditingController(text: companion.customName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Companion'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(companionProvider(companion.id).notifier)
                  .updateName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, WidgetRef ref, CompanionData companion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Companion'),
        content: Text('Remove ${companion.customName} from your company?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(companionRepositoryProvider);
              await repo.deleteCompanion(companion.id);
              if (context.mounted) {
                Navigator.pop(context);
                context.pop();
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CompanionHeader extends StatelessWidget {
  const _CompanionHeader({
    required this.companion,
    required this.type,
  });

  final CompanionData companion;
  final CompanionType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          PlaceholderImage(
            assetPath: 'assets/images/companions/${type.key}.png',
            category: 'companion',
            width: 64,
            height: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companion.customName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  type.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'RP: ${type.rpCost} | PP: ${companion.progressionPoints}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({
    required this.companion,
    required this.type,
  });

  final CompanionData companion;
  final CompanionType type;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Base Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              StatDisplay(label: 'Move', baseValue: type.move),
              StatDisplay(label: 'Fight', baseValue: type.fight),
              StatDisplay(label: 'Shoot', baseValue: type.shoot),
              StatDisplay(label: 'Armour', baseValue: type.armour),
              StatDisplay(label: 'Will', baseValue: type.will),
              StatDisplay(label: 'Health', baseValue: type.health),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Effective Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              StatDisplay(
                label: 'Move',
                baseValue: type.move,
                effectiveValue: companion.effectiveMove,
              ),
              StatDisplay(
                label: 'Fight',
                baseValue: type.fight,
                effectiveValue: companion.effectiveFight,
              ),
              StatDisplay(
                label: 'Shoot',
                baseValue: type.shoot,
                effectiveValue: companion.effectiveShoot,
              ),
              StatDisplay(
                label: 'Armour',
                baseValue: type.armour,
                effectiveValue: companion.effectiveArmour,
              ),
              StatDisplay(
                label: 'Will',
                baseValue: type.will,
                effectiveValue: companion.effectiveWill,
              ),
              StatDisplay(
                label: 'Health',
                baseValue: type.health,
                effectiveValue: companion.effectiveHealth,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillsTab extends StatelessWidget {
  const _SkillsTab({
    required this.companion,
    required this.type,
  });

  final CompanionData companion;
  final CompanionType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get all skills with their values
    final skillValues = <String, int>{};
    for (final skill in skills) {
      final baseValue = type.baseSkills[skill.key] ?? 0;
      final customValue = companion.customSkills[skill.key] ?? 0;
      skillValues[skill.key] = baseValue + customValue;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final value = skillValues[skill.key] ?? 0;

        return ListTile(
          title: Text(skill.name),
          subtitle: Text(
            skill.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: value > 0
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value > 0 ? '+$value' : '+0',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: value > 0
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InjuriesTab extends StatelessWidget {
  const _InjuriesTab({required this.companion});

  final CompanionData companion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (companion.permanentInjuries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Injuries',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This companion has no permanent injuries.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: companion.permanentInjuries.length,
      itemBuilder: (context, index) {
        final injury = companion.permanentInjuries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.warning_amber,
              color: theme.colorScheme.error,
            ),
            title: Text(injury.replaceAll('_', ' ').toUpperCase()),
            subtitle: const Text('Permanent injury'),
          ),
        );
      },
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.companion,
    required this.type,
  });

  final CompanionData companion;
  final CompanionType type;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSection(
            title: 'Description',
            content: type.description,
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Equipment',
            content: type.notes,
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Special Rules',
            content: type.specialRules ?? 'None',
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Recruitment Cost',
            content: '${type.rpCost} RP',
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
