import 'package:flutter/material.dart';

Color statusGreen(ThemeData theme) =>
    theme.brightness == Brightness.dark
        ? Colors.green.shade300
        : Colors.green.shade800;

Color statusOrange(ThemeData theme) =>
    theme.brightness == Brightness.dark
        ? Colors.orange.shade300
        : Colors.orange.shade800;

Color statusAmber(ThemeData theme) =>
    theme.brightness == Brightness.dark
        ? Colors.amber.shade300
        : Colors.amber.shade800;

Color statusBlue(ThemeData theme) =>
    theme.brightness == Brightness.dark
        ? Colors.lightBlue.shade300
        : Colors.blue.shade800;

Color statusPurple(ThemeData theme) =>
    theme.brightness == Brightness.dark
        ? Colors.purple.shade300
        : Colors.purple.shade700;

Color statusGrey(ThemeData theme) =>
    theme.colorScheme.onSurfaceVariant;
