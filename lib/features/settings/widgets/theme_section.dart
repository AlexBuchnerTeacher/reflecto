import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings_providers.dart';

/// Theme-Auswahl-Widget: System / Hell / Dunkel
class ThemeSection extends ConsumerWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    void setMode(AppThemeMode m) => ref.read(themeModeProvider.notifier).set(m);

    return SegmentedButton<AppThemeMode>(
      segments: const [
        ButtonSegment(
          value: AppThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.settings_suggest_outlined),
        ),
        ButtonSegment(
          value: AppThemeMode.light,
          label: Text('Hell'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: AppThemeMode.dark,
          label: Text('Dunkel'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (set) {
        final sel = set.first;
        setMode(sel);
      },
    );
  }
}
