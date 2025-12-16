import 'dart:io';

import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/folder_list.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/image_grid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ZipEditorPage extends ConsumerStatefulWidget {
  const ZipEditorPage({super.key});

  @override
  ConsumerState<ZipEditorPage> createState() => _ZipEditorPageState();
}

class _ZipEditorPageState extends ConsumerState<ZipEditorPage> {
  ZipDirectory? _selectedDirectory;

  @override
  Widget build(BuildContext context) {
    final directories = ref.watch(zipEditorProvider).cast<ZipDirectory>();

    // Auto-select first directory if none selected and directories exist
    if (_selectedDirectory == null && directories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedDirectory = directories.first;
        });
      });
    } else if (_selectedDirectory != null &&
        !directories.any((d) => d.name == _selectedDirectory!.name)) {
      // If selected directory was renamed/removed, try to find by new name or reset
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedDirectory =
              directories.isNotEmpty ? directories.first : null;
        });
      });
    } else if (_selectedDirectory != null) {
      // Update reference to the new object with same name
      final current = directories.firstWhere(
        (d) => d.name == _selectedDirectory!.name,
        orElse: () => _selectedDirectory!,
      );
      if (current != _selectedDirectory) {
        _selectedDirectory = current;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zip Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final bytes = ref.read(zipEditorProvider.notifier).saveZip();
              if (bytes == null) return;

              final result = await FilePicker.platform.saveFile(
                dialogTitle: 'Save Zip',
                fileName: 'edited_archive.zip',
                type: FileType.custom,
                allowedExtensions: ['zip'],
              );

              if (result != null) {
                final file = File(result);
                await file.writeAsBytes(bytes);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved successfully!')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: FolderList(
              directories: directories,
              selectedDirectory: _selectedDirectory,
              onDirectorySelected: (dir) {
                setState(() {
                  _selectedDirectory = dir;
                });
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _selectedDirectory == null
                ? const Center(child: Text('Select a folder'))
                : ImageGrid(directory: _selectedDirectory!),
          ),
        ],
      ),
    );
  }
}
