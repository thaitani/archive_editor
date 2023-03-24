import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:archive_editor/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(fileProvider);
    final archive = ref.watch(archiveProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          file?.name ?? 'Title',
        ),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.file_open),
          onPressed: () async {
            final fileResult = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
            if (fileResult != null) {
              ref.read(fileProvider.notifier).state = fileResult.files.first;
            }
          }),
      body: archive == null
          ? const SizedBox.shrink()
          : PageView.builder(
              itemCount: archive.files
                  .where((element) => !element.name.startsWith('__MACOSX'))
                  .length,
              controller: PageController(initialPage: 4),
              itemBuilder: (context, i) {
                return ref.watch(appDocDirProvider).whenData(
                  (value) {
                    final tmp = value.path;
                    final files = archive.files
                        .where(
                            (element) => !element.name.startsWith('__MACOSX'))
                        .toList();
                    final file = files[i];
                    if (!file.isFile) {
                      return const Text('not file');
                    }
                    final outputStream = OutputFileStream('$tmp/${file.name}');
                    file.writeContent(outputStream);
                    outputStream.close();
                    final outputFile = File('$tmp/${file.name}');
                    return Image.file(outputFile);
                  },
                ).value;
              },
            ),
    );
  }
}
