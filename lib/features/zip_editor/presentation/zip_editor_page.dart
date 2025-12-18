import 'package:archive_editor/core/services/file_saver_service.dart';
import 'package:archive_editor/features/settings/application/app_settings_provider.dart';
import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:archive_editor/features/zip_editor/presentation/dialogs/bulk_rename_dialog.dart';
import 'package:archive_editor/features/zip_editor/presentation/dialogs/rename_folder_dialog.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/config_load_button.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/folder_list.dart';
import 'package:archive_editor/features/zip_editor/presentation/widgets/image_grid.dart';
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

  Future<void> _showRenameDialog(
    BuildContext context,
    ZipDirectory directory,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return RenameFolderDialog(directory: directory);
      },
    );
  }

  Future<void> _showBulkRenameDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return const BulkRenameDialog();
      },
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

          final defaultPath =
              ref.read(appSettingsProvider).defaultSaveDirectory;

          await ref.read(fileSaverServiceProvider).saveZips(
                context,
                zips,
                defaultPath: defaultPath,
              );
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
