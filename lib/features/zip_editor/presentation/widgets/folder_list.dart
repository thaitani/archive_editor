import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FolderList extends ConsumerStatefulWidget {
  const FolderList({
    required this.directories,
    required this.onDirectorySelected,
    required this.selectedDirectory,
    super.key,
  });
  final List<ZipDirectory> directories;
  final ValueChanged<ZipDirectory> onDirectorySelected;
  final ZipDirectory? selectedDirectory;

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
          content: TextField(
            controller: _renameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newName = _renameController.text;
                if (newName.isNotEmpty && newName != directory.name) {
                  ref
                      .read(zipEditorProvider.notifier)
                      .renameDirectory(directory.name, newName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
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
          leading: const Icon(Icons.folder),
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
