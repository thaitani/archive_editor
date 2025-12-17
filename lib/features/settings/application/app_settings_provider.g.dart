// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppSettings)
const appSettingsProvider = AppSettingsProvider._();

final class AppSettingsProvider
    extends $NotifierProvider<AppSettings, AppSettingsState> {
  const AppSettingsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appSettingsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  AppSettings create() => AppSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsState>(value),
    );
  }
}

String _$appSettingsHash() => r'4c93ec5ac3f0c0733daaedb86fb7effe2b10a4a8';

abstract class _$AppSettings extends $Notifier<AppSettingsState> {
  AppSettingsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppSettingsState, AppSettingsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AppSettingsState, AppSettingsState>,
        AppSettingsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
