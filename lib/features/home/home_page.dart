import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_page.g.dart';

@riverpod
class InputFile extends _$InputFile {
  @override
  PlatformFile? build() {
    return null;
  }

  void setFile(PlatformFile file) {
    state = file;
  }
}

@riverpod
class InputArchive extends _$InputArchive {
  @override
  Archive? build() {
    final file = ref.watch(inputFileProvider);
    if (file == null) {
      return null;
    }
    final bytes = File(file.path!).readAsBytesSync();
    return ZipDecoder().decodeBytes(bytes);
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(inputFileProvider);
    final archive = ref.watch(inputArchiveProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          file?.name ?? 'No Title',
        ),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.file_open),
        onPressed: () async {
          final fileResult = await FilePicker.platform
              .pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
          if (fileResult != null) {
            ref
                .read(inputFileProvider.notifier)
                .setFile(fileResult.files.first);
          }
        },
      ),
      body: archive == null
          ? const SizedBox.shrink()
          : ListView.builder(
              itemCount: archive.files.length,
              controller: PageController(initialPage: 4),
              itemBuilder: (context, i) {
                final files = archive.files;
                final file = files[i];
                if (file.isFile) {
                  return ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(file.name),
                  );
                }
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(file.name),
                );
                // final outputStream = OutputFileStream('$tmp/${file.name}');
                // file.writeContent(outputStream);
                // outputStream.close();
                // final outputFile = File('$tmp/${file.name}');
                // return Image.file(outputFile);
              },
            ),
    );
  }
}
