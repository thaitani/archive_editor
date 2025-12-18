import 'dart:convert';
import 'dart:typed_data';

import 'package:archive_editor/core/services/file_saver_service.dart';
import 'package:archive_editor/features/settings/application/app_settings_provider.dart';
import 'package:archive_editor/features/zip_editor/application/name_suggestion_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSuggestions = ref.watch(nameSuggestionProvider);
    final searchText = _searchController.text.trim().toLowerCase();
    final suggestions = searchText.isEmpty
        ? allSuggestions
        : allSuggestions
            .where((s) => s.toLowerCase().contains(searchText))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Config File',
            onPressed: () async {
              final content = ref.read(nameSuggestionProvider).join('\n');
              final bytes = Uint8List.fromList(utf8.encode(content));

              await ref.read(fileSaverServiceProvider).saveFile(
                    context,
                    bytes,
                    'name_config.txt',
                  );
            },
          ),
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
      body: Column(
        children: [
          ListTile(
            title: const Text('Default Save Directory'),
            subtitle: Text(
              ref.watch(appSettingsProvider).defaultSaveDirectory ?? 'Not set',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () async {
                final path = await FilePicker.platform.getDirectoryPath(
                  dialogTitle: 'Select Default Save Directory',
                );
                if (path != null) {
                  await ref
                      .read(appSettingsProvider.notifier)
                      .setDefaultSaveDirectory(path);
                }
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: suggestions.isEmpty
                ? const Center(
                    child: Text(
                      'No configuration loaded or no match found.\n'
                      'Tap the upload icon to load a text file.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = suggestions[index];
                      return ListTile(
                        title: Text(suggestion),
                        leading: const Icon(Icons.label_outline),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await _showAddOrEditDialog(
                                  context,
                                  ref,
                                  existingName: suggestion,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await ref
                                    .read(nameSuggestionProvider.notifier)
                                    .remove(suggestion);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await _showAddOrEditDialog(context, ref);
        },
      ),
    );
  }

  Future<void> _showAddOrEditDialog(
    BuildContext context,
    WidgetRef ref, {
    String? existingName,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        final categoryController = TextEditingController();
        final authorController = TextEditingController();
        final titleController = TextEditingController();

        // If editing, try to parse the existing name
        if (existingName != null) {
          final regex = RegExp(r'^\((.*?)\)\[(.*?)\](.*)$');
          final match = regex.firstMatch(existingName);
          if (match != null) {
            categoryController.text = match.group(1) ?? '';
            authorController.text = match.group(2) ?? '';
            // For title, we should also separate volume if present, but the current UI
            // doesn't have a volume field in settings anymore (removed in earlier steps? wait, did I remove it?).
            // Checking previous file content...
            // Ah, the previous file content (Step 1722) lines 121-123 only has category, author, title.
            // But verify_task.md mentions 4 fields.
            // Let me check if volume should be there.
            // User request in Step 1626 created file with only 3 fields (Category, Author, Title).
            // But previous task list said "Update 'Add Name' dialog to use 4 fields".
            // It seems "Volume" might be part of Title or the regex logic needs to adapt.
            // Let's stick to what was in the file (3 fields) but maybe try to parse title intelligently?
            // Actually, let's just use the remainder as title for now to match current state.
            titleController.text = match.group(3) ?? existingName;
          } else {
            // Fallback if regex doesn't match
            titleController.text = existingName;
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            String getFormattedName() {
              final category = categoryController.text.trim();
              final author = authorController.text.trim();
              final title = titleController.text.trim();

              if (category.isEmpty && author.isEmpty && title.isEmpty) {
                return '';
              }

              final buffer = StringBuffer();
              if (category.isNotEmpty) buffer.write('($category)');
              if (author.isNotEmpty) buffer.write('[$author]');
              buffer.write(title);

              return buffer.toString();
            }

            return AlertDialog(
              title: Text(existingName == null ? 'Add Name' : 'Edit Name'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: categoryController,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Category'),
                      onChanged: (_) => setState(() {}),
                    ),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                      onChanged: (_) => setState(() {}),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Preview:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        getFormattedName().isEmpty
                            ? '(Category)[Author]Title v00'
                            : getFormattedName(),
                        style: TextStyle(
                          color: getFormattedName().isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final text = getFormattedName();
                    if (text.isNotEmpty) {
                      if (existingName != null) {
                        await ref
                            .read(nameSuggestionProvider.notifier)
                            .edit(existingName, text);
                      } else {
                        await ref
                            .read(nameSuggestionProvider.notifier)
                            .add(text);
                      }
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(existingName == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
