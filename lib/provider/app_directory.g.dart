// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_directory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appSupportDirectory)
const appSupportDirectoryProvider = AppSupportDirectoryProvider._();

final class AppSupportDirectoryProvider extends $FunctionalProvider<
        AsyncValue<Directory>, Directory, FutureOr<Directory>>
    with $FutureModifier<Directory>, $FutureProvider<Directory> {
  const AppSupportDirectoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appSupportDirectoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appSupportDirectoryHash();

  @$internal
  @override
  $FutureProviderElement<Directory> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Directory> create(Ref ref) {
    return appSupportDirectory(ref);
  }
}

String _$appSupportDirectoryHash() =>
    r'a1cf8c5e37686028bc16ecce9009e53912683219';

@ProviderFor(appDocumentDirectory)
const appDocumentDirectoryProvider = AppDocumentDirectoryProvider._();

final class AppDocumentDirectoryProvider extends $FunctionalProvider<
        AsyncValue<Directory>, Directory, FutureOr<Directory>>
    with $FutureModifier<Directory>, $FutureProvider<Directory> {
  const AppDocumentDirectoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appDocumentDirectoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appDocumentDirectoryHash();

  @$internal
  @override
  $FutureProviderElement<Directory> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Directory> create(Ref ref) {
    return appDocumentDirectory(ref);
  }
}

String _$appDocumentDirectoryHash() =>
    r'b2c20b2b4f24264fc471392d0efcdf2626763383';
