import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/ui/core/widgets/confirm_dialog.dart';
import 'package:rangers_mobile/ui/core/widgets/equipment_utils.dart';
import 'package:rangers_mobile/ui/core/widgets/placeholder_image.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/rangers_provider.dart';
import 'package:rangers_mobile/ui/features/rangers/views/tabs/ranger_abilities_tab.dart';
import 'package:rangers_mobile/ui/features/rangers/views/tabs/ranger_companions_tab.dart';
import 'package:rangers_mobile/ui/features/rangers/views/tabs/ranger_equipment_tab.dart';
import 'package:rangers_mobile/ui/features/rangers/views/tabs/ranger_injuries_tab.dart';
import 'package:rangers_mobile/ui/features/rangers/views/tabs/ranger_skills_tab.dart';
import 'package:rangers_mobile/ui/features/rangers/views/tabs/ranger_stats_tab.dart';

class RangerDetailView extends ConsumerStatefulWidget {
  const RangerDetailView({
    required this.rangerId,
    super.key,
  });

  final int rangerId;

  @override
  ConsumerState<RangerDetailView> createState() => _RangerDetailViewState();
}

class _RangerDetailViewState extends ConsumerState<RangerDetailView> {
  Future<void> _equipItem(RangerEquipmentData item) async {
    final repo = ref.read(rangerRepositoryProvider);
    final ranger = await ref.read(rangerDetailProvider(widget.rangerId).future);
    if (ranger == null) return;
    final usedSlots = ranger.equipment
      .where((e) => e.slotIndex != null)
      .map((e) => e.slotIndex!)
      .toSet();
    for (int i = 0; i < 6; i++) {
      if (!usedSlots.contains(i)) {
        await repo.updateRangerEquipment(RangerEquipmentCompanion(
          id: Value(item.id),
          slotIndex: Value(i),
          equippedBy: const Value('ranger'),
        ));
        ref.invalidate(rangerDetailProvider(widget.rangerId));
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rangerAsync = ref.watch(rangerDetailProvider(widget.rangerId));

    return rangerAsync.when(
      data: (ranger) {
        if (ranger == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Ranger')),
            body: const Center(child: Text('Ranger not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(ranger.ranger.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      _showRenameDialog(context, ref, ranger);
                      break;
                    case 'notes':
                      _showNotesDialog(context, ref, ranger);
                      break;
                    case 'companions':
                      context.push('/rangers/${widget.rangerId}/companions');
                      break;
                    case 'delete':
                      _showDeleteDialog(context, ref, ranger);
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
                  PopupMenuItem(
                    value: 'notes',
                    child: ListTile(
                      leading: Icon(ranger.ranger.notes.isEmpty ? Icons.note_add : Icons.edit_note),
                      title: Text(ranger.ranger.notes.isEmpty ? 'Add Note' : 'Edit Notes'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'companions',
                    child: ListTile(
                      leading: Icon(Icons.pets),
                      title: Text('View Companions'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                      title: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
                _RangerHeader(ranger: ranger),
                const TabBar(
                  isScrollable: true,
                  labelPadding: EdgeInsets.only(left: 8, right: 16),
                  tabs: [
                    Tab(text: 'Stats'),
                    Tab(text: 'Injuries'),
                    Tab(text: 'Abilities'),
                    Tab(text: 'Skills'),
                    Tab(text: 'Equipment'),
                    Tab(text: 'Companions'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      RangerStatsTab(
                        ranger: ranger,
                        statModifiers: computeEquipmentModifiers(ranger.equipment, equippedOnly: true),
                        onEditNotes: () => _showNotesDialog(context, ref, ranger),
                      ),
                      RangerInjuriesTab(ranger: ranger, rangerId: widget.rangerId),
                      RangerAbilitiesTab(ranger: ranger),
                      RangerSkillsTab(ranger: ranger),
                      RangerEquipmentTab(
                        ranger: ranger,
                        rangerId: widget.rangerId,
                        onEquip: _equipItem,
                      ),
                      RangerCompanionsTab(rangerId: widget.rangerId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Ranger')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Ranger')),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref, RangerDetail ranger) async {
    await showRenameDialog(
      context,
      title: 'Rename Ranger',
      currentName: ranger.ranger.name,
      onSave: (newName) async {
        final repo = ref.read(rangerRepositoryProvider);
        await repo.updateRangerFields(ranger.ranger.id, RangersCompanion(
          name: Value(newName),
          updatedAt: Value(DateTime.now()),
        ));
        ref.invalidate(rangerDetailProvider(widget.rangerId));
      },
    );
  }

  void _showNotesDialog(BuildContext context, WidgetRef ref, RangerDetail ranger) {
    final controller = TextEditingController(text: ranger.ranger.notes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ranger.ranger.notes.isEmpty ? 'Add Note' : 'Edit Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (ranger.ranger.notes.isNotEmpty)
            TextButton(
              onPressed: () async {
                final repo = ref.read(rangerRepositoryProvider);
                await repo.updateRangerFields(ranger.ranger.id, RangersCompanion(
                  notes: const Value(''),
                  updatedAt: Value(DateTime.now()),
                ));
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(rangerDetailProvider(widget.rangerId));
                }
              },
              child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              final repo = ref.read(rangerRepositoryProvider);
              await repo.updateRangerFields(ranger.ranger.id, RangersCompanion(
                notes: Value(text),
                updatedAt: Value(DateTime.now()),
              ));
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(rangerDetailProvider(widget.rangerId));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, RangerDetail ranger) async {
    await showConfirmDeleteDialog(
      context,
      title: 'Delete Ranger',
      message: 'Delete ${ranger.ranger.name}? This action cannot be undone.',
      confirmLabel: 'Delete',
      onConfirm: () async {
        final repo = ref.read(rangerRepositoryProvider);
        await repo.deleteRanger(ranger.ranger.id);
        ref.invalidate(rangerDetailProvider(widget.rangerId));
        ref.invalidate(rangersListProvider);
        if (context.mounted) context.go('/rangers');
      },
    );
  }
}

class _RangerHeader extends StatelessWidget {
  const _RangerHeader({required this.ranger});

  final RangerDetail ranger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ranger.ranger;

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const PlaceholderImage(
            assetPath: 'assets/images/rangers/default_ranger.png',
            category: 'ranger',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level ${r.level} | XP: ${r.experiencePoints}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'RP: ${r.baseRecruitmentPoints} | HP: ${r.currentHealth}/${r.health}',
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
