import 'package:archive_editor/features/zip_editor/application/name_suggestion_provider.dart';
import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulkRenameDialog extends ConsumerStatefulWidget {
  const BulkRenameDialog({super.key});

  @override
  ConsumerState<BulkRenameDialog> createState() => _BulkRenameDialogState();
}

class _BulkRenameDialogState extends ConsumerState<BulkRenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return AlertDialog(
      title: const Text('Bulk Rename'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This will rename ALL folders. Suffixes/Numbers will be preserved.',
          ),
          const SizedBox(height: 16),
          RawAutocomplete<String>(
            textEditingController: _controller,
            focusNode: FocusNode(),
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
              _controller.text = selection;
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Base Name',
                ),
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            onSelected(option);
                          },
                          child: ListTile(
                            title: Text(option),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
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
            final baseNewName = _controller.text;
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
                  suffix = suffix.replaceAllMapped(RegExp('[０-９]'), (match) {
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
  }
}
