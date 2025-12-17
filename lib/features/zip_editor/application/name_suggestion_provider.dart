import 'dart:convert';
import 'dart:io';

import 'package:archive_editor/features/settings/application/app_settings_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'name_suggestion_provider.g.dart';

const _kNameSuggestionsKey = 'name_suggestions';

@riverpod
class NameSuggestion extends _$NameSuggestion {
  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getStringList(_kNameSuggestionsKey) ?? [];
  }

  Future<void> loadConfig(PlatformFile file) async {
    final fileObj = File(file.path!);
    final content = await fileObj.readAsString();

    final newSuggestions = LineSplitter.split(content)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    state = newSuggestions;
    await _saveToPrefs(newSuggestions);
  }

  Future<void> add(String name) async {
    if (state.contains(name)) return;
    final newState = [...state, name];
    state = newState;
    await _saveToPrefs(newState);
  }

  Future<void> remove(String name) async {
    final newState = state.where((e) => e != name).toList();
    state = newState;
    await _saveToPrefs(newState);
  }

  Future<void> saveConfig(String path) async {
    final file = File(path);
    await file.writeAsString(state.join('\n'));
  }

  Future<void> _saveToPrefs(List<String> suggestions) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(_kNameSuggestionsKey, suggestions);
  }
}
