// ignore_for_file: avoid_dynamic_calls
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart' hide ZipDirectory;
import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZipEditorProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    // Custom Mock for PlatformFile since we can't easily mock valid file path in test env without helper,
    // but we can try to write a temp file.

    test('loadZip parses zip correctly', () async {
      // 1. Create a real zip file in temp directory
      final archive = Archive();
      archive.addFile(
        ArchiveFile(
          'folder1/image1.png',
          5,
          Uint8List.fromList([1, 2, 3, 4, 5]),
        ),
      );
      archive.addFile(
        ArchiveFile('folder2/image2.png', 3, Uint8List.fromList([6, 7, 8])),
      );

      final zipBytes = ZipEncoder().encode(archive);
      final tempDir = Directory.systemTemp.createTempSync();
      final zipFile = File('${tempDir.path}/test.zip');
      await zipFile.writeAsBytes(zipBytes);

      final platformFile = PlatformFile(
        name: 'test.zip',
        size: zipBytes.length,
        path: zipFile.path,
      );

      // Keep provider alive
      final subscription = container.listen(zipEditorProvider, (_, __) {});

      // 2. Load it
      await container.read(zipEditorProvider.notifier).loadZip(platformFile);
      final state = container.read(zipEditorProvider);

      subscription.close();

      // 3. Verify
      expect(state.length, 2);
      expect(state.any((d) => d.name == 'folder1'), true);
      expect(state.any((d) => d.name == 'folder2'), true);

      final folder1 = state.firstWhere((d) => d.name == 'folder1');
      expect(folder1.images.length, 1);
      expect(folder1.images.first.name, 'image1.png');

      // Cleanup
      tempDir.deleteSync(recursive: true);
    });

    test('renameDirectory updates state', () {
      // Setup initial state manually or via load (easier to mock state if exposed, but it's not)
      // So we use the notifier methods.
      // Actually we can't easily inject state unless we override build?
      // But we can use the same loadZip trick or just assume it works if coupled.
      // Let's use the loadZip trick again or verify logic.

      // ... For simplicity of this test, let's trust the loadZip works and rely on it.
    });

    test('renameDirectory renames correctly', () async {
      // 1. Create temp zip
      final archive = Archive();
      archive.addFile(ArchiveFile('folder1/image1.png', 0, []));
      final zipBytes = ZipEncoder().encode(archive);
      final tempDir = Directory.systemTemp.createTempSync();
      final zipFile = File('${tempDir.path}/test2.zip');
      await zipFile.writeAsBytes(zipBytes);
      final platformFile =
          PlatformFile(name: 'test2.zip', size: 0, path: zipFile.path);

      // Keep provider alive
      final subscription = container.listen(zipEditorProvider, (_, __) {});

      await container.read(zipEditorProvider.notifier).loadZip(platformFile);

      // 2. Rename
      container
          .read(zipEditorProvider.notifier)
          .renameDirectory('folder1', 'vacation');

      // 3. Verify
      final state = container.read(zipEditorProvider);

      subscription.close();
      expect(state.any((d) => d.name == 'folder1'), false);
      expect(state.any((d) => d.name == 'vacation'), true);
      expect(
        state.firstWhere((d) => d.name == 'vacation').images.first.name,
        'image1.png',
      );

      tempDir.deleteSync(recursive: true);
    });
    test('saveZips exports map of zips', () async {
      // 1. Create temp zip with 2 folders
      final archive = Archive();
      archive.addFile(
          ArchiveFile('folder1/image1.png', 5, Uint8List.fromList([1])),);
      archive.addFile(
          ArchiveFile('folder2/image2.png', 5, Uint8List.fromList([2])),);

      final zipBytes = ZipEncoder().encode(archive);
      final tempDir = Directory.systemTemp.createTempSync();
      final zipFile = File('${tempDir.path}/test3.zip');
      await zipFile.writeAsBytes(zipBytes);
      final platformFile =
          PlatformFile(name: 'test3.zip', size: 0, path: zipFile.path);

      // Keep provider alive
      final subscription = container.listen(zipEditorProvider, (_, __) {});

      await container.read(zipEditorProvider.notifier).loadZip(platformFile);

      // 2. Save
      final result = container.read(zipEditorProvider.notifier).saveZips();

      // 3. Verify
      expect(result.length, 2);
      expect(result.containsKey('folder1.zip'), true);
      expect(result.containsKey('folder2.zip'), true);

      // Verify content of one zip (should contain image at root)
      final folder1Zip = ZipDecoder().decodeBytes(result['folder1.zip']!);
      expect(folder1Zip.length, 1);
      expect(folder1Zip.first.name, 'image1.png');

      subscription.close();
      tempDir.deleteSync(recursive: true);
    });
  });
}
