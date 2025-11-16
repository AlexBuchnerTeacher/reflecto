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
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Einstellungen',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const VersionInfo(),
              const SizedBox(height: 24),

              // Theme
              const Text(
                'Darstellung',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const ThemeSection(),
              const SizedBox(height: 24),

              // Profile
              const Text(
                'Profil',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const ProfileSection(),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Wartung / Tools
              const Text(
                'Wartung',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const MaintenanceTools(),
            ],
          ),
        ),
      ),
    );
  }
}
