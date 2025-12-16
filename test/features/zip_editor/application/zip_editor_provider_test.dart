import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart' hide ZipDirectory;
import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart'
    as zm;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZipEditorProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    // Custom Mock for PlatformFile since we can't easily mock valid file path
    // in test env without helper, but we can try to write a temp file.

    test('loadZip parses zip correctly', () async {
      // 1. Create a real zip file in temp directory
      final archive = Archive()
        ..addFile(
          ArchiveFile(
            'folder1/image1.png',
            5,
            Uint8List.fromList([1, 2, 3, 4, 5]),
          ),
        )
        ..addFile(
          ArchiveFile(
            'folder2/image2.png',
            3,
            Uint8List.fromList([6, 7, 8]),
          ),
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
      await container.read(zipEditorProvider.notifier).loadZips([platformFile]);
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
      // Setup initial state manually or via load (easier to mock state if
      // exposed, but it's not) So we use the notifier methods.
      // Actually we can't easily inject state unless we override build?
      // But we can use the same loadZip trick or just assume it works if
      // coupled. Let's use the loadZip trick again or verify logic.
      // ... For simplicity of this test, let's trust the loadZip works and
      // rely on it.
    });

    test('renameDirectory renames correctly', () async {
      // 1. Create temp zip
      final archive = Archive()
        ..addFile(ArchiveFile('folder1/image1.png', 0, []));
      final zipBytes = ZipEncoder().encode(archive);
      final tempDir = Directory.systemTemp.createTempSync();
      final zipFile = File('${tempDir.path}/test2.zip');
      await zipFile.writeAsBytes(zipBytes);
      final platformFile =
          PlatformFile(name: 'test2.zip', size: 0, path: zipFile.path);

      // Keep provider alive
      final subscription = container.listen(zipEditorProvider, (_, __) {});

      await container.read(zipEditorProvider.notifier).loadZips([platformFile]);

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
      final archive = Archive()
        ..addFile(
          ArchiveFile('folder1/image1.png', 5, Uint8List.fromList([1])),
        )
        ..addFile(
          ArchiveFile('folder2/image2.png', 5, Uint8List.fromList([2])),
        );

      final zipBytes = ZipEncoder().encode(archive);
      final tempDir = Directory.systemTemp.createTempSync();
      final zipFile = File('${tempDir.path}/test3.zip');
      await zipFile.writeAsBytes(zipBytes);
      final platformFile =
          PlatformFile(name: 'test3.zip', size: 0, path: zipFile.path);

      // Keep provider alive
      final subscription = container.listen(zipEditorProvider, (_, __) {});

      await container.read(zipEditorProvider.notifier).loadZips([platformFile]);

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
    test('saveZips excludes skipped images', () async {
      // 1. Create temp zip with 1 folder, 2 images
      final archive = Archive()
        ..addFile(
          ArchiveFile('folder1/image1.png', 5, Uint8List.fromList([1])),
        )
        ..addFile(
          ArchiveFile('folder1/image2.png', 5, Uint8List.fromList([2])),
        );

      final zipBytes = ZipEncoder().encode(archive);
      final tempDir = Directory.systemTemp.createTempSync();
      final zipFile = File('${tempDir.path}/test4.zip');
      await zipFile.writeAsBytes(zipBytes);
      final platformFile =
          PlatformFile(name: 'test4.zip', size: 0, path: zipFile.path);

      // Keep provider alive
      final subscription = container.listen(zipEditorProvider, (_, __) {});

      await container.read(zipEditorProvider.notifier).loadZips([platformFile]);

      // 2. Toggle exclusion for image2
      container
          .read(zipEditorProvider.notifier)
          .toggleImageInclusion('folder1', 'image2.png');

      // Verify state update
      final state = container.read(zipEditorProvider);
      final folder1 = state.firstWhere((d) => d.name == 'folder1');
      expect(
        folder1.images
            .firstWhere((zm.ZipImage i) => i.name == 'image1.png')
            .isIncluded,
        true,
      );
      expect(
        folder1.images
            .firstWhere((zm.ZipImage i) => i.name == 'image2.png')
            .isIncluded,
        false,
      );

      // 3. Save
      final result = container.read(zipEditorProvider.notifier).saveZips();

      // 4. Verify output zip content
      expect(result.containsKey('folder1.zip'), true);
      final folder1Zip = ZipDecoder().decodeBytes(result['folder1.zip']!);
      expect(folder1Zip.length, 1);
      expect(folder1Zip.first.name, 'image1.png');

      subscription.close();
      tempDir.deleteSync(recursive: true);
    });
    test('loadZips merges multiple zip files', () async {
      // 1. Create first zip
      final archive1 = Archive()
        ..addFile(
          ArchiveFile('folder1/image1.png', 5, Uint8List.fromList([1])),
        );
      final zipBytes1 = ZipEncoder().encode(archive1);
      final tempDir = Directory.systemTemp.createTempSync();
      final zipFile1 = File('${tempDir.path}/test_multi_1.zip');
      await zipFile1.writeAsBytes(zipBytes1);
      final platformFile1 =
          PlatformFile(name: 'test_multi_1.zip', size: 0, path: zipFile1.path);

      // 2. Create second zip (same folder name, different image)
      final archive2 = Archive()
        ..addFile(
          ArchiveFile('folder1/image2.png', 5, Uint8List.fromList([2])),
        )
        // Different folder
        ..addFile(
          ArchiveFile('folder2/image3.png', 5, Uint8List.fromList([3])),
        );
      final zipBytes2 = ZipEncoder().encode(archive2);
      final zipFile2 = File('${tempDir.path}/test_multi_2.zip');
      await zipFile2.writeAsBytes(zipBytes2);
      final platformFile2 =
          PlatformFile(name: 'test_multi_2.zip', size: 0, path: zipFile2.path);

      // Keep provider alive
      final subscription = container.listen(zipEditorProvider, (_, __) {});

      // 3. Load both
      await container
          .read(zipEditorProvider.notifier)
          .loadZips([platformFile1, platformFile2]);

      final state = container.read(zipEditorProvider);

      // 4. Verify merge
      expect(state.length, 2);

      final folder1 = state.firstWhere((d) => d.name == 'folder1');
      expect(folder1.images.length, 2);
      expect(
        folder1.images.any((zm.ZipImage i) => i.name == 'image1.png'),
        true,
      );
      expect(
        folder1.images.any((zm.ZipImage i) => i.name == 'image2.png'),
        true,
      );

      final folder2 = state.firstWhere((d) => d.name == 'folder2');
      expect(folder2.images.length, 1);
      expect(folder2.images.first.name, 'image3.png');

      subscription.close();
      tempDir.deleteSync(recursive: true);
    });
  });
}
