import 'package:flutter_test/flutter_test.dart';
import 'package:map_tracking/main.dart';

void main() {
  testWidgets('App smoke test launches MapTrackingApp', (WidgetTester tester) async {
    await tester.pumpWidget(const MapTrackingApp());
    expect(find.byType(MapTrackingApp), findsOneWidget);
  });
}
