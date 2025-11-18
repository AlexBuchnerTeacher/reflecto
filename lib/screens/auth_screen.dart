import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/reflecto_button.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _handle(Future<UserCredential> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentifizierungsfehler')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ReflectoBreakpoints.contentMax,
              ),
              child: Padding(
                padding: const EdgeInsets.all(ReflectoSpacing.s24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Willkommen bei Reflecto',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: ReflectoSpacing.s12),
                    Text(
                      'Reflektiere deinen Tag und deine Woche.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),

                    // Email
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-Mail',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: ReflectoSpacing.s12),

                    // Password
                    TextField(
                      controller: _pwdCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Passwort',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: ReflectoSpacing.s16),

                    // Email actions
                    Row(
                      children: [
                        Expanded(
                          child: ReflectoButton(
                            text: 'Einloggen',
                            onPressed: _loading
                                ? null
                                : () => _handle(
                                      () => _auth.signInWithEmail(
                                        _emailCtrl.text.trim(),
                                        _pwdCtrl.text.trim(),
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: ReflectoSpacing.s12),
                        Expanded(
                          child: ReflectoButton(
                            text: 'Registrieren',
                            onPressed: _loading
                                ? null
                                : () => _handle(
                                      () => _auth.registerWithEmail(
                                        _emailCtrl.text.trim(),
                                        _pwdCtrl.text.trim(),
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: ReflectoSpacing.s16),
                    const Divider(height: 1),
                    const SizedBox(height: ReflectoSpacing.s16),

                    // Google
                    ReflectoButton(
                      text: 'Mit Google anmelden',
                      icon: Icons.login,
                      onPressed: _loading
                          ? null
                          : () => _handle(_auth.signInWithGoogle),
                    ),

                    if (_loading) ...[
                      const SizedBox(height: ReflectoSpacing.s24),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
