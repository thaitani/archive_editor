import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/config_load_button.dart';
import 'package:archive_editor/routes/router.dart';
import 'package:desktop_drop/desktop_drop.dart';
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
        actions: const [
          ConfigLoadButton(),
        ],
      ),
      body: DropTarget(
        onDragDone: (detail) async {
          final files = detail.files;
          final zipPlatformFiles = <PlatformFile>[];
          for (final xfile in files) {
            if (xfile.name.toLowerCase().endsWith('.zip')) {
              final length = await xfile.length();
              zipPlatformFiles.add(
                PlatformFile(
                  path: xfile.path,
                  name: xfile.name,
                  size: length,
                ),
              );
            }
          }

          if (zipPlatformFiles.isNotEmpty) {
            try {
              await ref
                  .read(zipEditorProvider.notifier)
                  .loadZips(zipPlatformFiles);

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
        onDragEntered: (detail) {
          // Optional: Add visual feedback
        },
        onDragExited: (detail) {
          // Optional: Remove visual feedback
        },
        child: Center(
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
              const Text(
                'Drop Zip files here or click button',
                style: TextStyle(color: Colors.grey),
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
      ),
    );
  }
}
