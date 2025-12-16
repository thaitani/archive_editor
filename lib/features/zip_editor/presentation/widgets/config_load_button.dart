import 'package:archive_editor/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigLoadButton extends ConsumerWidget {
  const ConfigLoadButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Load Name Config',
      onPressed: () {
        const SettingsRoute().push<void>(context);
      },
    );
  }
}
