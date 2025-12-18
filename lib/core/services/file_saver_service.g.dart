// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_saver_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fileSaverService)
const fileSaverServiceProvider = FileSaverServiceProvider._();

final class FileSaverServiceProvider extends $FunctionalProvider<
    FileSaverService,
    FileSaverService,
    FileSaverService> with $Provider<FileSaverService> {
  const FileSaverServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fileSaverServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fileSaverServiceHash();

  @$internal
  @override
  $ProviderElement<FileSaverService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileSaverService create(Ref ref) {
    return fileSaverService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileSaverService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileSaverService>(value),
    );
  }
}

String _$fileSaverServiceHash() => r'9eb18bbe5dbac2413be0a715a185562cdfd5c446';
