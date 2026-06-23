import 'package:flutter_test/flutter_test.dart';

import 'package:drivereader/main.dart';

void main() {
  testWidgets('Home screen shows KevDex identity', (WidgetTester tester) async {
    await tester.pumpWidget(const DriveReaderApp());

    expect(find.text('KevDex'), findsOneWidget);
    expect(find.text('Read Anywhere.'), findsOneWidget);
    expect(find.text('Open Reader'), findsOneWidget);
    expect(find.text('By Kevin and Dora-chan'), findsOneWidget);
  });
}
