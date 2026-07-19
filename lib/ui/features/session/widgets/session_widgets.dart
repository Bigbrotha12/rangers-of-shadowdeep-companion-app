import 'package:flutter/material.dart';
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';

// ── Turn Tracker ──

class TurnTracker extends StatelessWidget {
  const TurnTracker({required this.session, super.key});

  final ActiveSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.turn_right, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Turn ${session.currentTurn}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (session.missionName.isNotEmpty)
            Text(
              session.missionName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Phase Indicator ──

class PhaseIndicator extends StatelessWidget {
  const PhaseIndicator({
    required this.currentPhase,
    required this.onNextPhase,
    super.key,
  });

  final SessionPhase currentPhase;
  final VoidCallback onNextPhase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const phases = SessionPhase.values;
    final phaseNames = ['Ranger', 'Creature', 'Companion', 'Event'];
    final phaseIcons = [Icons.person, Icons.pets, Icons.group, Icons.event];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < phases.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _PhaseChip(
                  label: phaseNames[i],
                  icon: phaseIcons[i],
                  isActive: phases[i] == currentPhase,
                  isPast: phases[i].index < currentPhase.index,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: onNextPhase,
              child: const Text('Next Phase'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isPast,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : isPast
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive
                ? theme.colorScheme.onPrimary
                : isPast
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : isPast
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Event Log ──

class EventLog extends StatelessWidget {
  const EventLog({required this.session, super.key});

  final ActiveSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Log',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (session.eventLog.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No events yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...session.eventLog.reversed.take(20).map((event) => EventTile(event: event)),
      ],
    );
  }
}

class EventTile extends StatelessWidget {
  const EventTile({required this.event, super.key});

  final EventLogEntry event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (event.eventType) {
      case 'damage':
        icon = Icons.local_fire_department;
        color = theme.colorScheme.error;
        break;
      case 'heal':
        icon = Icons.favorite;
        color = statusGreen(theme);
        break;
      case 'ability_used':
        icon = Icons.auto_awesome;
        color = statusPurple(theme);
        break;
      case 'spell_cast':
        icon = Icons.cast;
        color = statusBlue(theme);
        break;
      case 'skill_roll':
        icon = Icons.casino;
        color = statusOrange(theme);
        break;
      case 'death':
        icon = Icons.dangerous;
        color = theme.colorScheme.error;
        break;
      default:
        icon = Icons.note;
        color = theme.colorScheme.onSurfaceVariant;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          event.description,
          style: theme.textTheme.bodySmall,
        ),
        subtitle: Text(
          'Turn ${event.turnNumber} • ${event.phase.name}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
