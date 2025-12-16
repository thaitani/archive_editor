import 'dart:io';

import 'package:archive_editor/features/zip_editor/application/name_suggestion_provider.dart';
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
  final Set<String> _checkedFolders = {};

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
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Zips',
            onPressed: () async {
              final zips = ref.read(zipEditorProvider.notifier).saveZips();
              if (zips.isEmpty) return;

              final directoryPath = await FilePicker.platform.getDirectoryPath(
                dialogTitle: 'Select Directory to Save Zips',
              );

              if (directoryPath != null) {
                try {
                  for (final entry in zips.entries) {
                    final file = File('$directoryPath/${entry.key}');
                    await file.writeAsBytes(entry.value);
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Saved ${zips.length} zips successfully!'),
                      ),
                    );
                  }
                } on Object catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save zips: $e')),
                    );
                  }
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
            child: Column(
              children: [
                if (directories.isNotEmpty)
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Select All'),
                    value: _checkedFolders.length == directories.length,
                    onChanged: (value) {
                      setState(() {
                        if (value ?? false) {
                          _checkedFolders
                              .addAll(directories.map((d) => d.name));
                        } else {
                          _checkedFolders.clear();
                        }
                      });
                    },
                  ),
                Expanded(
                  child: FolderList(
                    directories: directories,
                    selectedDirectory: _selectedDirectory,
                    onDirectorySelected: (dir) {
                      setState(() {
                        _selectedDirectory = dir;
                      });
                    },
                    checkedDirectories: _checkedFolders,
                    onDirectoryChecked: (name, isChecked) {
                      setState(() {
                        if (isChecked) {
                          _checkedFolders.add(name);
                        } else {
                          _checkedFolders.remove(name);
                        }
                      });
                    },
                  ),
                ),
              ],
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
