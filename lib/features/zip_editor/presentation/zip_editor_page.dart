import 'dart:io';

import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/config_load_button.dart';
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
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final directories = ref.watch(zipEditorProvider).cast<ZipDirectory>();

    // Auto-select first directory if none selected and directories exist
    if (!_isInitialized && directories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedDirectory = directories.first;
          _checkedFolders.addAll(directories.map((d) => d.id));
          _isInitialized = true;
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
        (d) => d.id == _selectedDirectory!.id,
        orElse: () => _selectedDirectory!,
      );
      if (current != _selectedDirectory) {
        _selectedDirectory = current;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zip Editor'),
        actions: const [
          ConfigLoadButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save Zips',
        onPressed: () async {
          final zips = ref
              .read(zipEditorProvider.notifier)
              .saveZips(filterIds: _checkedFolders);
          if (zips.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No folders selected to save.'),
                ),
              );
            }
            return;
          }

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
                    content: Text('Saved ${zips.length} zips successfully!'),
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
        child: const Icon(Icons.save),
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
                          _checkedFolders.addAll(directories.map((d) => d.id));
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
                    onDirectoryChecked: (id, {required isChecked}) {
                      setState(() {
                        if (isChecked) {
                          _checkedFolders.add(id);
                        } else {
                          _checkedFolders.remove(id);
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
