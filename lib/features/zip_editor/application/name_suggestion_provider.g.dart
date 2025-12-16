// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name_suggestion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NameSuggestion)
const nameSuggestionProvider = NameSuggestionProvider._();

final class NameSuggestionProvider
    extends $NotifierProvider<NameSuggestion, List<String>> {
  const NameSuggestionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'nameSuggestionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$nameSuggestionHash();

  @$internal
  @override
  NameSuggestion create() => NameSuggestion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$nameSuggestionHash() => r'fc94dd048b761f1439334e6f27a5341ae95cb976';

abstract class _$NameSuggestion extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<String>, List<String>>,
        List<String>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
