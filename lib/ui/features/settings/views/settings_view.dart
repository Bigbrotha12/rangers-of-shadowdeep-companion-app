import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/services/backup_service_provider.dart';

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
                    color: theme.colorScheme.primary,
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
                    color: theme.colorScheme.primary,
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
          _sectionHeader(context, 'About'),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Rangers of Shadow Deep'),
              subtitle: const Text('Version 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.exportToFile();
      if (context.mounted) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Backup exported successfully'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import backup'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'This will replace ALL existing rangers, companions, '
              'sessions, and other data with the contents of the '
              'backup file. This cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
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
      final backupService = ref.read(backupServiceProvider);
      final result = await backupService.importFromFile();

      if (result.cancelled) return;

      if (context.mounted) {
        if (result.success) {
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
        } else {
          scaffold.showSnackBar(
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
        scaffold.showSnackBar(
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
