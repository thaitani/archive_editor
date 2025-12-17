import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FolderList extends ConsumerWidget {
  const FolderList({
    required this.directories,
    required this.onDirectorySelected,
    required this.selectedDirectory,
    required this.checkedDirectories,
    required this.onDirectoryChecked,
    required this.onRenamePressed,
    super.key,
  });

  final List<ZipDirectory> directories;
  final ValueChanged<ZipDirectory> onDirectorySelected;
  final ZipDirectory? selectedDirectory;
  final Set<String> checkedDirectories;
  final void Function(String, {required bool isChecked}) onDirectoryChecked;
  final void Function(ZipDirectory) onRenamePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: directories.length,
      itemBuilder: (context, index) {
        final directory = directories[index];
        final isSelected = selectedDirectory == directory;
        return ListTile(
          selected: isSelected,
          leading: Checkbox(
            value: checkedDirectories.contains(directory.id),
            onChanged: (value) => onDirectoryChecked(
              directory.id,
              isChecked: value ?? false,
            ),
          ),
          title: Text(directory.name),
          onTap: () => onDirectorySelected(directory),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onRenamePressed(directory),
          ),
        );
      },
    );
  }
}
