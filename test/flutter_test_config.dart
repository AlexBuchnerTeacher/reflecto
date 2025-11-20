import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

/// Test-Konfiguration für Golden Tests
///
/// Standard-Setup für konsistente Golden Test Ausführung
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  return testMain();
}
