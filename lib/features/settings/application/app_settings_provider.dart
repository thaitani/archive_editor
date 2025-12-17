import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_settings_provider.g.dart';

// Key for shared preferences
const _kDefaultSaveDirectoryKey = 'default_save_directory';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class AppSettingsState {
  const AppSettingsState({this.defaultSaveDirectory});
  final String? defaultSaveDirectory;

  AppSettingsState copyWith({String? defaultSaveDirectory}) {
    return AppSettingsState(
      defaultSaveDirectory: defaultSaveDirectory ?? this.defaultSaveDirectory,
    );
  }
}

@riverpod
class AppSettings extends _$AppSettings {
  @override
  AppSettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettingsState(
      defaultSaveDirectory: prefs.getString(_kDefaultSaveDirectoryKey),
    );
  }

  Future<void> setDefaultSaveDirectory(String path) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kDefaultSaveDirectoryKey, path);
    state = state.copyWith(defaultSaveDirectory: path);
  }
}
