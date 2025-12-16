// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zip_editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ZipEditor)
const zipEditorProvider = ZipEditorProvider._();

final class ZipEditorProvider
    extends $NotifierProvider<ZipEditor, List<dynamic>> {
  const ZipEditorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'zipEditorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$zipEditorHash();

  @$internal
  @override
  ZipEditor create() => ZipEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<dynamic>>(value),
    );
  }
}

String _$zipEditorHash() => r'644dcdd18fb4d0784fb35e10a0e7e8daa0d484d2';

abstract class _$ZipEditor extends $Notifier<List<dynamic>> {
  List<dynamic> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<dynamic>, List<dynamic>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<dynamic>, List<dynamic>>,
        List<dynamic>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
