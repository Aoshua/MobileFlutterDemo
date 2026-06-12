import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/article/data/article_detail_repository_impl.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_detail_controller.g.dart';

@riverpod
class ArticleDetailController extends _$ArticleDetailController {
  @override
  // Normally providers using @riverpod are singleton, but when you have a
  // parameterized build(), then you get separate cached instances:
  // articleDetailControllerProvider(42) and articleDetailControllerProvider(99)
  // are two separate cached instances.
  Future<ArticleDetail> build(int id) async {
    final result = await ref
        .read(articleDetailRepositoryProvider)
        .getArticleDetail(id: id);
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }
}
