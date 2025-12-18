import 'dart:convert';
import 'dart:typed_data';

import 'package:archive_editor/core/services/file_saver_service.dart';
import 'package:archive_editor/features/settings/application/app_settings_provider.dart';
import 'package:archive_editor/features/settings/presentation/dialogs/add_edit_name_dialog.dart';
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
        return AddEditNameDialog(existingName: existingName);
      },
    );
  }
}
