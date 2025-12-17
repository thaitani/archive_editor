import 'dart:io';

import 'package:archive_editor/features/settings/application/app_settings_provider.dart';
import 'package:archive_editor/features/zip_editor/application/name_suggestion_provider.dart';
import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/config_load_button.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/folder_list.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/image_grid.dart';
import 'package:archive_editor/routes/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _showRenameDialog(
    BuildContext context,
    ZipDirectory directory,
  ) async {
    final controller = TextEditingController(text: directory.name);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Folder'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'New Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text;
                if (newName.isNotEmpty && newName != directory.name) {
                  ref
                      .read(zipEditorProvider.notifier)
                      .renameDirectory(directory.id, newName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

// ... (other imports)

  Future<void> _showBulkRenameDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bulk Rename'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This will rename ALL folders. Suffixes/Numbers will be preserved.',
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final suggestions = ref.read(nameSuggestionProvider);
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return suggestions.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  controller.text = selection;
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  if (fieldTextEditingController.text.isEmpty &&
                      controller.text.isNotEmpty) {
                    fieldTextEditingController.text = controller.text;
                  }
                  fieldTextEditingController.addListener(() {
                    controller.text = fieldTextEditingController.text;
                  });

                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Base Name',
                    ),
                  );
                },
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  final text = value.text;
                  final regex =
                      RegExp(r'^\(([^)]+)\)\[([^\]]+)\](.*?)(?:\s+(v\d+))?$');
                  final match = regex.firstMatch(text);

                  if (match == null) {
                    return const SizedBox.shrink();
                  }

                  final category = match.group(1)?.trim() ?? '';
                  final author = match.group(2)?.trim() ?? '';
                  final title = match.group(3)?.trim() ?? '';
                  final volume = match.group(4)?.trim() ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Category', category),
                        _buildInfoRow('Author', author),
                        _buildInfoRow('Title', title),
                        if (volume.isNotEmpty) _buildInfoRow('Volume', volume),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final baseNewName = controller.text;
                if (baseNewName.isNotEmpty) {
                  final directories =
                      ref.read(zipEditorProvider).cast<ZipDirectory>();
                  final uniqueNames = directories.map((d) => d.name).toSet();

                  for (final targetName in uniqueNames) {
                    var newName = baseNewName;
                    if (newName == targetName) continue;

                    // Check for any 1-3 digit numbers (half or full width)
                    final matches =
                        RegExp('([0-9０-９]{1,3})').allMatches(targetName);
                    if (matches.isNotEmpty) {
                      var suffix = matches.last.group(0)!;

                      // Convert full-width to half-width
                      suffix =
                          suffix.replaceAllMapped(RegExp('[０-９]'), (match) {
                        return String.fromCharCode(
                          match.group(0)!.codeUnitAt(0) - 0xFEE0,
                        );
                      });

                      if (suffix.length == 1) {
                        newName = '$newName v0$suffix';
                      } else {
                        newName = '$newName v$suffix';
                      }
                    }

                    // Apply to all directories matching this name
                    final matchingDirs =
                        directories.where((d) => d.name == targetName);
                    for (final dir in matchingDirs) {
                      ref
                          .read(zipEditorProvider.notifier)
                          .renameDirectory(dir.id, newName);
                    }
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Rename All'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: value));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied "$value" to clipboard'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value)),
            const Icon(Icons.copy, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

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

          final defaultPath =
              ref.read(appSettingsProvider).defaultSaveDirectory;
          final directoryPath = await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'Select Directory to Save Zips',
            initialDirectory: defaultPath,
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
                const HomeRoute().go(context);
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
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton.icon(
                      onPressed: () => _showBulkRenameDialog(context),
                      icon: const Icon(Icons.drive_file_rename_outline),
                      label: const Text('Bulk Rename'),
                    ),
                  ),
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
                    onRenamePressed: (dir) => _showRenameDialog(context, dir),
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
