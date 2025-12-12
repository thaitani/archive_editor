import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_directory.g.dart';

@riverpod
FutureOr<Directory> appSupportDirectory(Ref ref) {
  return getApplicationSupportDirectory();
}

@riverpod
FutureOr<Directory> appDocumentDirectory(Ref ref) {
  return getApplicationDocumentsDirectory();
}

class AppDirectoryProvider extends ConsumerWidget {
  const AppDirectoryProvider({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appDocDir = ref.watch(appDocumentDirectoryProvider).asData;
    if (appDocDir == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final appSupDir = ref.watch(appSupportDirectoryProvider).asData;
    if (appSupDir == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return child;
  }
}
