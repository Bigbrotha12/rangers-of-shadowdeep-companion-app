import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    required this.assetPath,
    required this.category,
    this.width = 64,
    this.height = 64,
    this.borderRadius = 8,
    super.key,
  });

  final String assetPath;
  final String category;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon(theme);
          },
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    IconData icon;
    switch (category) {
      case 'ranger':
        icon = Icons.person;
        break;
      case 'companion':
        icon = Icons.group;
        break;
      case 'weapon':
        icon = Icons.linear_scale;
        break;
      case 'armour':
        icon = Icons.shield;
        break;
      case 'magic_item':
        icon = Icons.auto_awesome;
        break;
      case 'herb_potion':
        icon = Icons.science;
        break;
      case 'gear':
        icon = Icons.build;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Icon(
      icon,
      size: width * 0.5,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }
}
