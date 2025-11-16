import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/tokens.dart';
import '../features/settings/widgets/theme_section.dart';
import '../features/settings/widgets/maintenance_tools.dart';
import '../features/settings/widgets/profile_section.dart';
import '../features/settings/widgets/version_info.dart';

/// Einstellungen-Screen: Profil, Theme, Wartung
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const maxWidth = ReflectoBreakpoints.contentMax;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(ReflectoSpacing.s24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Einstellungen',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: ReflectoSpacing.s8),
              const VersionInfo(),
              const SizedBox(height: ReflectoSpacing.s24),

              // Theme
              Text(
                'Darstellung',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ReflectoSpacing.s8),
              const ThemeSection(),
              const SizedBox(height: ReflectoSpacing.s24),

              // Profile
              Text('Profil', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: ReflectoSpacing.s8),
              const ProfileSection(),
              const SizedBox(height: ReflectoSpacing.s24),
              const Divider(),
              const SizedBox(height: ReflectoSpacing.s12),

              // Wartung / Tools
              Text('Wartung', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: ReflectoSpacing.s8),
              const MaintenanceTools(),
            ],
          ),
        ),
      ),
    );
  }
}
