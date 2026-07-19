import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/ui/core/widgets/confirm_dialog.dart';
import 'package:rangers_mobile/ui/core/widgets/placeholder_image.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';
import 'package:rangers_mobile/ui/features/companions/views/tabs/companion_stats_tab.dart';
import 'package:rangers_mobile/ui/features/companions/views/tabs/companion_skills_tab.dart';
import 'package:rangers_mobile/ui/features/companions/views/tabs/companion_abilities_tab.dart';
import 'package:rangers_mobile/ui/features/companions/views/tabs/companion_injuries_tab.dart';
import 'package:rangers_mobile/ui/features/companions/views/tabs/companion_info_tab.dart';
import 'package:rangers_mobile/ui/features/companions/views/tabs/companion_animal_equipment_disabled.dart';
import 'package:rangers_mobile/ui/features/companions/views/tabs/companion_equipment_tab.dart';

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
              PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  title: Text('Remove', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 6,
        child: Column(
          children: [
            _CompanionHeader(companion: companion, type: type),
            const TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.only(left: 8, right: 16),
              tabs: [
                Tab(text: 'Stats'),
                Tab(text: 'Skills'),
                Tab(text: 'Abilities'),
                Tab(text: 'Injuries'),
                Tab(text: 'Info'),
                Tab(text: 'Equipment'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CompanionStatsTab(
                    companion: companion,
                    type: type,
                    rangerId: rangerId,
                    companionId: companionId,
                  ),
                  CompanionSkillsTab(companion: companion, type: type),
                  CompanionAbilitiesTab(
                    companion: companion,
                    type: type,
                    rangerId: rangerId,
                  ),
                  CompanionInjuriesTab(companion: companion),
                  CompanionInfoTab(companion: companion, type: type),
                  type.isAnimal
                      ? const CompanionAnimalEquipmentDisabled()
                      : CompanionEquipmentTab(
                          rangerId: rangerId,
                          companionId: companionId,
                          type: type,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref, CompanionData companion) async {
    await showRenameDialog(
      context,
      title: 'Rename Companion',
      currentName: companion.customName,
      onSave: (newName) async {
        ref.read(companionProvider(companion.id).notifier).updateName(newName);
      },
    );
  }

  Future<void> _showRemoveDialog(BuildContext context, WidgetRef ref, CompanionData companion) async {
    await showConfirmDeleteDialog(
      context,
      title: 'Remove Companion',
      message: 'Remove ${companion.customName} from your company?',
      confirmLabel: 'Remove',
      onConfirm: () async {
        final repo = ref.read(companionRepositoryProvider);
        await repo.deleteCompanion(companion.id);
        ref.invalidate(rangerDetailProvider);
        if (context.mounted) context.pop();
      },
    );
  }
}

class _CompanionHeader extends StatelessWidget {
  const _CompanionHeader({
    required this.companion,
    required this.type,
  });

  final CompanionData companion;
  final CompanionTypeDefinition type;

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
