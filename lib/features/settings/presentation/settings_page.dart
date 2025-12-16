import 'package:archive_editor/features/zip_editor/application/name_suggestion_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(nameSuggestionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Load Config File',
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
          ),
        ],
      ),
      body: suggestions.isEmpty
          ? const Center(
              child: Text(
                'No configuration loaded.\n'
                'Tap the upload icon to load a text file.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]),
                  leading: const Icon(Icons.label_outline),
                );
              },
            ),
    );
  }
}
