import 'dart:io';
import 'dart:typed_data';

import 'package:archive_editor/routes/router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'file_saver_service.g.dart';

@riverpod
FileSaverService fileSaverService(Ref ref) {
  return FileSaverService();
}

class FileSaverService {
  Future<void> saveZips(
    BuildContext context,
    Map<String, Uint8List> zips, {
    String? defaultPath,
  }) async {
    if (zips.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No folders selected to save.'),
          ),
        );
      }
      return;
    }

    if (Platform.isIOS) {
      await _shareZipsIOS(context, zips);
    } else {
      await _saveZipsDesktop(context, zips, defaultPath);
    }
  }

  Future<void> _shareZipsIOS(
    BuildContext context,
    Map<String, Uint8List> zips,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = <XFile>[];

      for (final entry in zips.entries) {
        final file = File('${tempDir.path}/${entry.key}');
        // Ensure directory exists if needed, though usually tempDir is flat
        // or we just write file. For zip names like "foo.zip", it's just a file.
        await file.writeAsBytes(entry.value);
        files.add(XFile(file.path));
      }

      if (context.mounted) {
        await SharePlus.instance.share(ShareParams(files: files));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shared zips successfully!'),
            ),
          );
        }
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share zips: $e')),
        );
      }
    }
  }

  Future<void> _saveZipsDesktop(
    BuildContext context,
    Map<String, Uint8List> zips,
    String? defaultPath,
  ) async {
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Directory to Save Zips',
      initialDirectory: defaultPath,
    );

    if (directoryPath != null) {
      try {
        for (final entry in zips.entries) {
          final file = File('$directoryPath/${entry.key}');
          await file.writeAsBytes(entry.value);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved ${zips.length} zips successfully!'),
            ),
          );
          const HomeRoute().go(context);
        }
      } on Object catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save zips: $e')),
          );
        }
      }
    }
  }

  Future<void> saveFile(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    if (Platform.isIOS) {
      await _shareFileIOS(context, bytes, fileName);
    } else {
      await _saveFileDesktop(context, bytes, fileName);
    }
  }

  Future<void> _shareFileIOS(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Shared $fileName successfully!'),
            ),
          );
        }
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share file: $e')),
        );
      }
    }
  }

  Future<void> _saveFileDesktop(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save File',
      fileName: fileName,
    );

    if (result != null) {
      try {
        final file = File(result);
        await file.writeAsBytes(bytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved $fileName successfully!'),
            ),
          );
        }
      } on Object catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save file: $e')),
          );
        }
      }
    }
  }
}
