import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/database/app_database.dart' show Session;
import '../view_models/session_provider.dart';
import '../../../core/theme/app_colors.dart';

class SessionListView extends ConsumerWidget {
  const SessionListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Sessions'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sessions_fab',
        onPressed: () => context.push('/session/setup'),
        icon: const Icon(Icons.play_arrow),
        label: const Text('New Session'),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.casino_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your first game session!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/session/setup'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Session'),
                  ),
                ],
              ),
            );
          }

          // Split into active and completed
          final activeSessions = sessions.where((s) => !s.isCompleted).toList();
          final completedSessions = sessions.where((s) => s.isCompleted).toList();

          return ListView(
            children: [
              // Active Sessions
              if (activeSessions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'ACTIVE SESSIONS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...activeSessions.map((session) => _SessionCard(
                  session: session,
                  isActive: true,
                  onTap: () => context.go('/session/active/${session.id}'),
                  onDelete: () => _confirmDeleteActive(context, ref, session),
                )),
              ],

              // Completed Sessions
              if (completedSessions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'COMPLETED SESSIONS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...completedSessions.map((session) => _SessionCard(
                  session: session,
                  isActive: false,
                  onTap: () => _showSessionSummary(context, session),
                )),
              ],
              const SizedBox(height: 80), // Space for FAB
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showSessionSummary(BuildContext context, Session session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _SessionSummarySheet(
          session: session,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _confirmDeleteActive(BuildContext context, WidgetRef ref, Session session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
          'Delete "${session.scenarioName}"? This will permanently delete this active session. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              deleteSession(ref, session.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.isActive,
    required this.onTap,
    this.onDelete,
  });

  final Session session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color outcomeColor;
    IconData outcomeIcon;
    String outcomeText;

    switch (session.outcome) {
      case 'victory':
        outcomeColor = statusGreen(theme);
        outcomeIcon = Icons.emoji_events;
        outcomeText = 'Victory';
        break;
      case 'defeat':
        outcomeColor = theme.colorScheme.error;
        outcomeIcon = Icons.dangerous;
        outcomeText = 'Defeat';
        break;
      case 'partial':
        outcomeColor = statusOrange(theme);
        outcomeIcon = Icons.trending_up;
        outcomeText = 'Partial';
        break;
      default:
        outcomeColor = theme.colorScheme.onSurfaceVariant;
        outcomeIcon = Icons.help_outline;
        outcomeText = 'In Progress';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isActive ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Outcome icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.primaryContainer
                      : outcomeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? Icons.play_arrow : outcomeIcon,
                  color: isActive ? theme.colorScheme.primary : outcomeColor,
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.scenarioName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (session.missionName.isNotEmpty)
                      Text(
                        session.missionName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(session.datePlayed),
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.turn_right, size: 12, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${session.turnsPlayed} turns',
                          style: theme.textTheme.labelSmall,
                        ),
                        if (session.experienceEarned > 0) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.star, size: 12, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${session.experienceEarned} XP',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Outcome badge
              if (!isActive && session.outcome.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: outcomeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    outcomeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: outcomeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isActive)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error.withValues(alpha: 0.7)),
                  onPressed: onDelete,
                  tooltip: 'Delete session',
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _SessionSummarySheet extends ConsumerWidget {
  const _SessionSummarySheet({
    required this.session,
    required this.scrollController,
  });

  final Session session;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  session.scenarioName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (session.missionName.isNotEmpty)
                  Text(
                    session.missionName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),

          const Divider(),

          // Stats
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Outcome
                if (session.outcome.isNotEmpty)
                  _SummaryRow(
                    icon: session.outcome == 'victory'
                        ? Icons.emoji_events
                        : session.outcome == 'defeat'
                            ? Icons.dangerous
                            : Icons.trending_up,
                    label: 'Outcome',
                    value: session.outcome.toUpperCase(),
                    valueColor: session.outcome == 'victory'
                        ? statusGreen(theme)
                        : session.outcome == 'defeat'
                            ? theme.colorScheme.error
                            : statusOrange(theme),
                  ),

                _SummaryRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: _formatDateTime(session.datePlayed),
                ),

                _SummaryRow(
                  icon: Icons.turn_right,
                  label: 'Turns Played',
                  value: '${session.turnsPlayed}',
                ),

                if (session.experienceEarned > 0)
                  _SummaryRow(
                    icon: Icons.star,
                    label: 'Experience Earned',
                    value: '${session.experienceEarned} XP',
                    valueColor: theme.colorScheme.primary,
                  ),

                if (session.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Notes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        session.notes,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],

                // Delete
                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: const Text('Delete Session'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    onPressed: () => _confirmDelete(context, ref, session.id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
          'This will permanently delete this session and all associated events. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // close the bottom sheet
              deleteSession(ref, sessionId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
