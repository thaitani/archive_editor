import 'dart:io';

import 'package:archive_editor/app.dart';
import 'package:archive_editor/i18n/strings.g.dart';
import 'package:archive_editor/provider/app_directory.dart';
import 'package:archive_editor/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.shout(details);
    if (kReleaseMode) exit(1);
  };
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    TranslationProvider(
      child: const ProviderScope(
        child: AppDirectoryProvider(child: App()),
      ),
    ),
  );
}
