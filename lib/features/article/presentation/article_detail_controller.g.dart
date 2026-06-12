// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$articleDetailControllerHash() =>
    r'c49b85f8c0eb837c40616a32269839b079936867';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ArticleDetailController
    extends BuildlessAutoDisposeAsyncNotifier<ArticleDetail> {
  late final int id;

  FutureOr<ArticleDetail> build(int id);
}

/// See also [ArticleDetailController].
@ProviderFor(ArticleDetailController)
const articleDetailControllerProvider = ArticleDetailControllerFamily();

/// See also [ArticleDetailController].
class ArticleDetailControllerFamily extends Family<AsyncValue<ArticleDetail>> {
  /// See also [ArticleDetailController].
  const ArticleDetailControllerFamily();

  /// See also [ArticleDetailController].
  ArticleDetailControllerProvider call(int id) {
    return ArticleDetailControllerProvider(id);
  }

  @override
  ArticleDetailControllerProvider getProviderOverride(
    covariant ArticleDetailControllerProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articleDetailControllerProvider';
}

/// See also [ArticleDetailController].
class ArticleDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ArticleDetailController,
          ArticleDetail
        > {
  /// See also [ArticleDetailController].
  ArticleDetailControllerProvider(int id)
    : this._internal(
        () => ArticleDetailController()..id = id,
        from: articleDetailControllerProvider,
        name: r'articleDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleDetailControllerHash,
        dependencies: ArticleDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            ArticleDetailControllerFamily._allTransitiveDependencies,
        id: id,
      );

  ArticleDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  FutureOr<ArticleDetail> runNotifierBuild(
    covariant ArticleDetailController notifier,
  ) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(ArticleDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ArticleDetailControllerProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ArticleDetailController,
    ArticleDetail
  >
  createElement() {
    return _ArticleDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleDetailControllerProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticleDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ArticleDetail> {
  /// The parameter `id` of this provider.
  int get id;
}

class _ArticleDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ArticleDetailController,
          ArticleDetail
        >
    with ArticleDetailControllerRef {
  _ArticleDetailControllerProviderElement(super.provider);

  @override
  int get id => (origin as ArticleDetailControllerProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
