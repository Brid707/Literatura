import 'package:flutter_test/flutter_test.dart';

import 'package:literatura/main.dart';
import 'package:literatura/core/factories/app_service_factory.dart';

void main() {
  testWidgets('renders the login screen when there is no session', (
    WidgetTester tester,
  ) async {
    final facade = AppServiceFactory.libraryFacade();
    await facade.init();

    await tester.pumpWidget(MyApp(facade: facade));

    expect(find.text('Literatura Rusa - Login'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
