import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail.dart';

abstract interface class ArticleDetailRepository {
  Future<Result<ArticleDetail, AppFailure>> getArticleDetail({required int id});
}
