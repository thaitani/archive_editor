import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart' hide ZipDirectory;
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'zip_editor_provider.g.dart';

@riverpod
class ZipEditor extends _$ZipEditor {
  @override
  List<ZipDirectory> build() {
    ref.keepAlive();
    return [];
  }

  Future<void> loadZip(PlatformFile file) async {
    final bytes = await File(file.path!).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final groupedFiles = <String, List<ZipImage>>{};

    for (final file in archive) {
      if (!file.isFile) continue;

      // Extract directory name.
      // archive file name includes path, e.g. "folder/image.png"
      // or just "image.png" if root.
      final fileName = file.name;
      final directoryName = p.dirname(fileName);

      // Skip __MACOSX and other hidden folders if necessary,
      // but strictly following requirement "folders of images".
      if (directoryName.startsWith('__MACOSX')) continue;
      if (p.basename(fileName).startsWith('.')) continue;

      // Handle root files if we want, or put them in a "root" folder.
      // For now, let's treat "." as root.
      final dirKey = directoryName == '.' ? 'Root' : directoryName;

      final content = file.content as List<int>;
      final zipImage = ZipImage(
        name: p.basename(fileName),
        content: Uint8List.fromList(content),
      );

      if (!groupedFiles.containsKey(dirKey)) {
        groupedFiles[dirKey] = [];
      }
      groupedFiles[dirKey]!.add(zipImage);
    }

    state = groupedFiles.entries.map((entry) {
      return ZipDirectory(name: entry.key, images: entry.value);
    }).toList();
  }

  void renameDirectory(String oldName, String newName) {
    state = [
      for (final ZipDirectory dir in state.cast<ZipDirectory>())
        if (dir.name == oldName) dir.copyWith(name: newName) else dir,
    ];
  }

  Uint8List? saveZip() {
    final archive = Archive();

    for (final dir in state.cast<ZipDirectory>()) {
      for (final img in dir.images) {
        final path = dir.name == 'Root' ? img.name : '${dir.name}/${img.name}';
        final file = ArchiveFile(path, img.content.length, img.content);
        archive.addFile(file);
      }
    }

    return ZipEncoder().encode(archive) as Uint8List?;
  }
}
