import 'package:archive_editor/app.dart';
import 'package:archive_editor/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    TranslationProvider(
      child: const ProviderScope(
        child: App(),
      ),
    ),
  );
}
