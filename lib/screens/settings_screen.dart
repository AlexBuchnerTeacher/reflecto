import 'package:flutter/material.dart';
import '../widgets/reflecto_button.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _signOut() async {
    setState(() => _loading = true);
    try {
      await _auth.signOut();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Einstellungen',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ReflectoButton(
                text: _loading ? 'Abmelden…' : 'Abmelden',
                icon: Icons.logout,
                onPressed: _loading ? null : _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
