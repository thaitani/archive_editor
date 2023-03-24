import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:archive_editor/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

final fileProvider = StateProvider<PlatformFile?>((ref) {
  return;
});

final archiveProvider = StateProvider<Archive?>((ref) {
  final file = ref.watch(fileProvider);
  if (file == null) {
    return null;
  }
  final bytes = File(file.path!).readAsBytesSync();
  return ZipDecoder().decodeBytes(bytes);
});

final appDocDirProvider =
    FutureProvider<Directory>((ref) => getApplicationDocumentsDirectory());

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}
