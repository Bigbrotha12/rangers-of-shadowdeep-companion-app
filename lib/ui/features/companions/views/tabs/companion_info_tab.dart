import 'package:flutter/material.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';

class CompanionInfoTab extends StatelessWidget {
  const CompanionInfoTab({
    required this.companion,
    required this.type,
    super.key,
  });

  final CompanionData companion;
  final CompanionTypeDefinition type;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanionInfoSection(
            title: 'Description',
            content: type.description,
          ),
          const SizedBox(height: 16),
          CompanionInfoSection(
            title: 'Equipment',
            content: type.notes,
          ),
          const SizedBox(height: 16),
          CompanionInfoSection(
            title: 'Special Rules',
            content: type.specialRules ?? 'None',
          ),
          const SizedBox(height: 16),
          CompanionInfoSection(
            title: 'Recruitment Cost',
            content: '${type.rpCost} RP',
          ),
        ],
      ),
    );
  }
}

class CompanionInfoSection extends StatelessWidget {
  const CompanionInfoSection({
    required this.title,
    required this.content,
    super.key,
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
