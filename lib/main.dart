import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart' as intl_data;
import 'package:intl/intl.dart' as intl;
import 'app.dart';
import 'providers/card_collapse_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _bootstrap();
}

Future<void> _bootstrap() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Enable offline persistence for Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  try {
    // Initialize german locale data for intl (used in DayScreen)
    intl.Intl.defaultLocale = 'de_DE';
    await intl_data.initializeDateFormatting('de_DE', null);
  } catch (_) {
    // Keep running even if locale init fails; DateFormat falls back.
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ReflectoApp(),
    ),
  );
}
