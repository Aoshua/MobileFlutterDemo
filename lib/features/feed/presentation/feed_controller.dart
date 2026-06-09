import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_repository_impl.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_controller.g.dart';

@riverpod
class FeedController extends _$FeedController {
  static const _perPage = 20;
  var _page = 1;
  var _hasMore = true;

  @override
  Future<List<Article>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPage(_page);
  }

  Future<void> loadNextPage() async {
    if (!_hasMore) return;
    if (state is AsyncLoading) return;

    final current = state.valueOrNull ?? [];
    state = const AsyncLoading();

    final next = _page + 1;
    final result = await _repo.getArticles(page: next, perPage: _perPage);

    switch (result) {
      case Ok(:final value):
        _page = next;
        _hasMore = value.length == _perPage;
        state = AsyncData([...current, ...value]);
      case Err():
        // Restore previous data so the existing list stays visible
        state = AsyncData(current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _page = 1;
    _hasMore = true;
    try {
      state = AsyncData(await _fetchPage(1));
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  ArticleRepository get _repo => ref.read(articleRepositoryProvider);

  Future<List<Article>> _fetchPage(int page) async {
    final result = await _repo.getArticles(page: page, perPage: _perPage);
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error, // Caught by AsyncNotifier.build -> AsyncError
    };
  }
}