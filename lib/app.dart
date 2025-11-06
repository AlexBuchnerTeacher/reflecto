import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/reflecto_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class ReflectoApp extends StatelessWidget {
  const ReflectoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reflecto',
      debugShowCheckedModeBanner: false,
      theme: ReflectoTheme.light(),
      darkTheme: ReflectoTheme.dark(),
      themeMode: ThemeMode.system,
      home: Consumer(
        builder: (context, ref, _) {
          final authStream = FirebaseAuth.instance.authStateChanges();
          return StreamBuilder<User?>(
            stream: authStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _Splash();
              }
              if (snapshot.hasData) {
                return const HomeScreen();
              }
              return const AuthScreen();
            },
          );
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
