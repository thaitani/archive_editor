import 'dart:io';

import 'package:archive_editor/app.dart';
import 'package:archive_editor/features/settings/application/app_settings_provider.dart';
import 'package:archive_editor/i18n/strings.g.dart';
import 'package:archive_editor/provider/app_directory.dart';
import 'package:archive_editor/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.shout(details);
    if (kReleaseMode) exit(1);
  };
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const AppDirectoryProvider(child: App()),
      ),
    ),
  );
}
