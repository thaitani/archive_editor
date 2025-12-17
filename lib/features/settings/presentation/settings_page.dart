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
            icon: const Icon(Icons.download),
            tooltip: 'Export Config File',
            onPressed: () async {
              final result = await FilePicker.platform.saveFile(
                dialogTitle: 'Save Name Config',
                fileName: 'name_config.txt',
                allowedExtensions: ['txt'],
                type: FileType.custom,
              );

              if (result != null) {
                await ref
                    .read(nameSuggestionProvider.notifier)
                    .saveConfig(result);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name config saved')),
                  );
                }
              }
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
                final suggestion = suggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  leading: const Icon(Icons.label_outline),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref
                          .read(nameSuggestionProvider.notifier)
                          .remove(suggestion);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await showDialog<void>(
            context: context,
            builder: (context) {
              final categoryController = TextEditingController();
              final authorController = TextEditingController();
              final titleController = TextEditingController();
              final volumeController = TextEditingController();

              return StatefulBuilder(
                builder: (context, setState) {
                  String getFormattedName() {
                    final category = categoryController.text.trim();
                    final author = authorController.text.trim();
                    final title = titleController.text.trim();
                    final volume = volumeController.text.trim();

                    if (category.isEmpty &&
                        author.isEmpty &&
                        title.isEmpty &&
                        volume.isEmpty) {
                      return '';
                    }

                    final buffer = StringBuffer();
                    if (category.isNotEmpty) buffer.write('($category)');
                    if (author.isNotEmpty) buffer.write('[$author]');
                    buffer.write(title);
                    if (volume.isNotEmpty) buffer.write(' $volume');

                    return buffer.toString();
                  }

                  return AlertDialog(
                    title: const Text('Add Name'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: categoryController,
                            autofocus: true,
                            decoration:
                                const InputDecoration(labelText: 'Category'),
                            onChanged: (_) => setState(() {}),
                          ),
                          TextField(
                            controller: authorController,
                            decoration:
                                const InputDecoration(labelText: 'Author'),
                            onChanged: (_) => setState(() {}),
                          ),
                          TextField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: 'Title'),
                            onChanged: (_) => setState(() {}),
                          ),
                          TextField(
                            controller: volumeController,
                            decoration:
                                const InputDecoration(labelText: 'Volume'),
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
                        onPressed: () {
                          final text = getFormattedName();
                          if (text.isNotEmpty) {
                            ref.read(nameSuggestionProvider.notifier).add(text);
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
