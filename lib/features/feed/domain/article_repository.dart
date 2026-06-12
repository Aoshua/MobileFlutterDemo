import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';

// "abstract interface class" is a class that con only be implemented,
// not extended. Using an interface here allows us to swap implementations
// (real API, fake, cached) without changing a single widget
abstract interface class ArticleRepository {
  Future<Result<List<Article>, AppFailure>> getArticles({
    required int page,
    int perPage = 20,
  });
}
