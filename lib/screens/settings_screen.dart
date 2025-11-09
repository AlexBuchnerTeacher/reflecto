import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/reflecto_button.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../providers/settings_providers.dart';
import '../utils/build_info.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _auth = AuthService();
  bool _loading = false;
  final _nameCtrl = TextEditingController();
  String? _email;
  String? _version;
  String? _buildInfo;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _email = user?.email;
    _nameCtrl.text = user?.displayName ?? '';
    _loadVersion();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    // Show semantic version (from pubspec) and keep build/meta in separate row.
    final version = info.version;
    final displayTime =
        kBuildTime; // nur anzeigen, wenn Build-Time gesetzt wurde
    // Compose build string: buildNumber + channel + shortSha + time (where available)
    final resolvedBuildNumber = (kBuildNumber.isNotEmpty)
        ? kBuildNumber
        : info.buildNumber;
    final buildParts = <String>[
      if (resolvedBuildNumber.isNotEmpty && resolvedBuildNumber != '0')
        resolvedBuildNumber,
      if ((kBuildChannel).isNotEmpty) kBuildChannel else 'local',
      if (shortGitSha().isNotEmpty) shortGitSha(),
      if (displayTime.isNotEmpty) displayTime,
    ];
    final build = buildParts.where((e) => e.isNotEmpty).join(' ');
    setState(() {
      _version = version;
      _buildInfo = build;
    });
  }

  Future<void> _signOut() async {
    setState(() => _loading = true);
    try {
      await _auth.signOut();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) return;
    setState(() => _loading = true);
    try {
      await user.updateDisplayName(newName);
      await FirestoreService().saveUserData(
        AppUser(
          uid: user.uid,
          displayName: newName,
          email: user.email,
          photoUrl: user.photoURL,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil gespeichert')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 820.0;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('Version'), Text(_version ?? '\u2026')],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('Build'), Text(_buildInfo ?? '')],
              ),
              const SizedBox(height: 24),

              // Theme
              const Text(
                'Darstellung',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const _ThemeSection(),
              const SizedBox(height: 24),

              // Profile
              const Text(
                'Profil',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Anzeigename',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_email != null && _email!.isNotEmpty)
                Text(
                  'E-Mail: $_email',
                  style: const TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ReflectoButton(
                  text: _loading ? 'Speichern\u2026' : 'Profil speichern',
                  icon: Icons.save_outlined,
                  onPressed: _loading ? null : _saveProfile,
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Abmelden
              Align(
                alignment: Alignment.centerLeft,
                child: ReflectoButton(
                  text: _loading ? 'Abmelden\u2026' : 'Abmelden',
                  icon: Icons.logout_outlined,
                  onPressed: _loading ? null : _signOut,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();
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
