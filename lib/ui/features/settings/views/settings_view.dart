import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:rangers_mobile/data/services/backup_service_provider.dart';
import 'package:rangers_mobile/ui/core/theme/preferences.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _sectionHeader(context, 'Data Backup'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.upload,
                    color: theme.colorScheme.secondary,
                  ),
                  title: const Text('Export backup'),
                  subtitle: const Text(
                    'Save all rangers, companions, and sessions to a JSON file',
                  ),
                  onTap: () => _exportBackup(context, ref),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: Icon(
                    Icons.download,
                    color: theme.colorScheme.secondary,
                  ),
                  title: const Text('Import backup'),
                  subtitle: const Text(
                    'Restore data from a previously exported JSON file',
                  ),
                  onTap: () => _importBackup(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader(context, 'Theme'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: theme.colorScheme.secondary),
                      const SizedBox(width: 12),
                      Text('Appearance', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SegmentedButton<ThemeModePref>(
                      segments: const [
                        ButtonSegment(value: ThemeModePref.system, label: Text('System'), icon: Icon(Icons.brightness_auto, size: 16)),
                        ButtonSegment(value: ThemeModePref.light, label: Text('Light'), icon: Icon(Icons.light_mode, size: 16)),
                        ButtonSegment(value: ThemeModePref.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode, size: 16)),
                      ],
                      selected: {ref.watch(themeModeNotifier)},
                      onSelectionChanged: (v) => ref.read(themeModeNotifier.notifier).update(v.first),
                      showSelectedIcon: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader(context, 'About'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rangers of Shadow Deep Companion',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Divider(height: 1, indent: 16),
                  Text(
                    'A companion app for the tabletop RPG Rangers of Shadow Deep.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Features:\n'
                    '• Create and manage rangers\n'
                    '• Recruit and progress companions\n'
                    '• Track game sessions in real-time\n'
                    '• Post-game bookkeeping\n'
                    '• Rules reference',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'This app stores all data locally with no authentication or cloud syncing.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.lg, bottom: Spacing.sm, left: Spacing.xs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final backupService = ref.read(backupServiceProvider);
      final path = await backupService.exportToFile();
      if (context.mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Backup saved: ${p.basename(path)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final backupService = ref.read(backupServiceProvider);
    final files = await backupService.listBackupFiles();

    if (files.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No backup files found. Export a backup first.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final selectedPath = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select backup'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (context, index) {
              final filePath = files[index];
              final fileName = p.basename(filePath);
              return ListTile(
                title: Text(fileName),
                subtitle: Text(filePath),
                onTap: () => Navigator.pop(context, filePath),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedPath == null || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.tertiary, size: 48),
            const SizedBox(height: 16),
            const Text(
              'This will replace ALL existing rangers, companions, '
              'sessions, and other data with the contents of the '
              'backup file. This cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Recommendation: Export a backup of your current data '
              'first before proceeding.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final scaffold = ScaffoldMessenger.of(context);
    try {
      final result = await backupService.importFromFile(selectedPath);

      if (result.cancelled) return;

      if (context.mounted) {
        if (result.success) {
          if (result.rangers == 0 &&
              result.companions == 0 &&
              result.sessions == 0) {
            scaffold.showSnackBar(
              const SnackBar(
                content: Text('Import successful, but no data was restored.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            scaffold.showSnackBar(
              SnackBar(
                content: Text(
                  'Import successful: ${result.rangers} ranger(s), '
                  '${result.companions} companion(s), '
                  '${result.sessions} session(s) restored.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (context.mounted) context.go('/rangers');
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: ${result.errorMessage}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
