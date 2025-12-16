import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/routes/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive Editor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Archive Editor',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                final fileResult = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['zip'],
                  allowMultiple: true,
                );
                if (fileResult != null && fileResult.files.isNotEmpty) {
                  // Show loading indicator or something?
                  // For now async await is fine.
                  try {
                    await ref
                        .read(zipEditorProvider.notifier)
                        .loadZips(fileResult.files);

                    if (context.mounted) {
                      const ZipEditorRoute().go(context);
                    }
                  } on Object catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to load zip: $e')),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Open Zip File'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
