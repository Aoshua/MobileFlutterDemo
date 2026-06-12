import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_repository_impl.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article_repository.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/feed_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late MockArticleRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockArticleRepository();
    container = ProviderContainer(
      overrides: [articleRepositoryProvider.overrideWithValue(mockRepo)],
    );
    addTearDown(container.dispose);
  });

  test('transitions AsyncLoading → AsyncData on success', () async {
    when(
      () => mockRepo.getArticles(page: 1, perPage: any(named: 'perPage')),
    ).thenAnswer((_) async => Ok(_fakeArticles(3)));

    expect(
      container.read(feedControllerProvider),
      const AsyncLoading<List<Article>>(),
    );

    await container.read(feedControllerProvider.future);

    expect(
      container.read(feedControllerProvider),
      isA<AsyncData<List<Article>>>(),
    );
  });

  test('transitions AsyncLoading → AsyncError on failure', () async {
    when(
      () => mockRepo.getArticles(page: 1, perPage: any(named: 'perPage')),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    await expectLater(
      container.read(feedControllerProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
    expect(
      container.read(feedControllerProvider),
      isA<AsyncError<List<Article>>>(),
    );
  });
}

List<Article> _fakeArticles(int count) => List.generate(
  count,
  (i) => Article(
    id: i,
    title: 'Article $i',
    description: 'Desc $i',
    url: 'https://dev.to/$i',
    username: 'user',
    userProfileImage: 'https://img',
    positiveReactionsCount: 0,
    commentsCount: 0,
    publishedAt: DateTime(2024),
    tags: const [],
  ),
);
