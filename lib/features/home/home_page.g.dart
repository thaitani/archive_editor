// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InputFile)
const inputFileProvider = InputFileProvider._();

final class InputFileProvider
    extends $NotifierProvider<InputFile, PlatformFile?> {
  const InputFileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inputFileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inputFileHash();

  @$internal
  @override
  InputFile create() => InputFile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlatformFile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlatformFile?>(value),
    );
  }
}

String _$inputFileHash() => r'f9f0c7622260463ee55019c0c2594349007724a9';

abstract class _$InputFile extends $Notifier<PlatformFile?> {
  PlatformFile? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PlatformFile?, PlatformFile?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PlatformFile?, PlatformFile?>,
        PlatformFile?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(InputArchive)
const inputArchiveProvider = InputArchiveProvider._();

final class InputArchiveProvider
    extends $NotifierProvider<InputArchive, Archive?> {
  const InputArchiveProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inputArchiveProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inputArchiveHash();

  @$internal
  @override
  InputArchive create() => InputArchive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Archive? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Archive?>(value),
    );
  }
}

String _$inputArchiveHash() => r'78e692cec49903737d9e1bf9ec223bc0eca2f24e';

abstract class _$InputArchive extends $Notifier<Archive?> {
  Archive? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Archive?, Archive?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Archive?, Archive?>, Archive?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
