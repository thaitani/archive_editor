import 'package:archive_editor/features/zip_editor/application/name_suggestion_provider.dart';
import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FolderList extends ConsumerStatefulWidget {
  const FolderList({
    required this.directories,
    required this.onDirectorySelected,
    required this.selectedDirectory,
    required this.checkedDirectories,
    required this.onDirectoryChecked,
    super.key,
  });
  final List<ZipDirectory> directories;
  final ValueChanged<ZipDirectory> onDirectorySelected;
  final ZipDirectory? selectedDirectory;
  final Set<String> checkedDirectories;
  final void Function(String, {required bool isChecked}) onDirectoryChecked;

  @override
  ConsumerState<FolderList> createState() => _FolderListState();
}

class _FolderListState extends ConsumerState<FolderList> {
  final TextEditingController _renameController = TextEditingController();

  Future<void> _showRenameDialog(
    BuildContext context,
    ZipDirectory directory,
  ) async {
    _renameController.text = directory.name;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Folder'),
          content: Column(
            children: [
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
                  _renameController.text = selection;
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  // Sync local controller with field controller if needed or
                  // just use field controller
                  // Effectively we want to pre-fill it.
                  if (fieldTextEditingController.text.isEmpty &&
                      _renameController.text.isNotEmpty) {
                    fieldTextEditingController.text = _renameController.text;
                  }

                  // We need to keep our _renameController in sync for the
                  // "Rename" button
                  fieldTextEditingController.addListener(() {
                    _renameController.text = fieldTextEditingController.text;
                  });

                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'New Name',
                    ),
                  );
                },
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _renameController,
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
                final baseNewName = _renameController.text;
                if (baseNewName.isNotEmpty) {
                  final uniqueNames =
                      widget.directories.map((d) => d.name).toSet();

                  for (final targetName in uniqueNames) {
                    var newName = baseNewName;
                    if (newName == targetName) continue;

                    // Check for any 2-3 digit numbers
                    final matches = RegExp(r'(\d{1,3})').allMatches(targetName);
                    if (matches.isNotEmpty) {
                      final suffix = matches.last.group(0)!;
                      if (suffix.length == 1) {
                        newName = '$newName v0$suffix';
                      } else {
                        newName = '$newName v$suffix';
                      }
                    }

                    // Apply to all directories matching this name
                    final matchingDirs =
                        widget.directories.where((d) => d.name == targetName);
                    for (final dir in matchingDirs) {
                      ref
                          .read(zipEditorProvider.notifier)
                          .renameDirectory(dir.id, newName);
                    }
                  }
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
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
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.directories.length,
      itemBuilder: (context, index) {
        final directory = widget.directories[index];
        final isSelected = widget.selectedDirectory == directory;
        return ListTile(
          selected: isSelected,
          leading: Checkbox(
            value: widget.checkedDirectories.contains(directory.id),
            onChanged: (value) => widget.onDirectoryChecked(
              directory.id,
              isChecked: value ?? false,
            ),
          ),
          title: Text(directory.name),
          onTap: () => widget.onDirectorySelected(directory),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await _showRenameDialog(context, directory);
            },
          ),
        );
      },
    );
  }
}
