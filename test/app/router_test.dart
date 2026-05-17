import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter_demo/app/app.dart';
import 'package:mobile_flutter_demo/features/activity/presentation/activity_page.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/feed_page.dart';
import 'package:mobile_flutter_demo/features/profile/presentation/profile_page.dart';
import 'package:mobile_flutter_demo/features/search/presentation/search_page.dart';

void main() {
  testWidgets('Bottom nav switches branches and updates AppBar title',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    expect(find.byType(FeedPage), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Search'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Search'), findsOneWidget);
    expect(find.byType(SearchPage), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Activity'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Activity'), findsOneWidget);
    expect(find.byType(ActivityPage), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Profile'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
    expect(find.byType(ProfilePage), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    expect(find.byType(FeedPage), findsOneWidget);
  });
}
