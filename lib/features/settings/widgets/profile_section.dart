import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';
import '../../../widgets/reflecto_button.dart';
import '../../../theme/tokens.dart';

/// Profil-Bereich: Anzeigename bearbeiten und speichern
class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  bool _loading = false;
  final _nameCtrl = TextEditingController();
  String? _email;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _email = user?.email;
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FocusTraversalOrder(
          order: const NumericFocusOrder(1.0),
          child: TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Anzeigename',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(height: ReflectoSpacing.s8),
        if (_email != null && _email!.isNotEmpty)
          Text('E-Mail: $_email', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: ReflectoSpacing.s8),
        Align(
          alignment: Alignment.centerLeft,
          child: FocusTraversalOrder(
            order: const NumericFocusOrder(2.0),
            child: ReflectoButton(
              text: _loading ? 'Speichern…' : 'Profil speichern',
              icon: Icons.save_outlined,
              onPressed: _loading ? null : _saveProfile,
            ),
          ),
        ),
      ],
    );
  }
}
