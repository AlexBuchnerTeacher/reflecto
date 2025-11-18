import 'package:flutter/material.dart';

class ReflectoSnackbar {
  static void showSaved(BuildContext context) {
    final theme = Theme.of(context).snackBarTheme;
    final snack = SnackBar(
      content: const Text('✓ Gespeichert'),
      behavior: theme.behavior ?? SnackBarBehavior.floating,
      width: theme.width ?? 400,
      duration: const Duration(milliseconds: 1500),
      shape: theme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: theme.backgroundColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snack);
  }
}
