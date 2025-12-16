import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'name_suggestion_provider.g.dart';

@riverpod
class NameSuggestion extends _$NameSuggestion {
  @override
  List<String> build() {
    ref.keepAlive();
    return [];
  }

  Future<void> loadConfig(PlatformFile file) async {
    final fileObj = File(file.path!);
    final content = await fileObj.readAsString();

    state = LineSplitter.split(content)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void add(String name) {
    if (state.contains(name)) return;
    state = [...state, name];
  }

  void remove(String name) {
    state = state.where((e) => e != name).toList();
  }
}
