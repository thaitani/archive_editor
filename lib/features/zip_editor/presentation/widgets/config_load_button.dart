import 'package:archive_editor/features/zip_editor/application/name_suggestion_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigLoadButton extends ConsumerWidget {
  const ConfigLoadButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Load Name Config',
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['txt'],
        );
        if (result != null && result.files.isNotEmpty) {
          await ref
              .read(nameSuggestionProvider.notifier)
              .loadConfig(result.files.first);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Name config loaded')),
            );
          }
        }
      },
    );
  }
}
