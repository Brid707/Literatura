import 'package:flutter/material.dart';
import 'core/factories/app_service_factory.dart';
import 'core/facades/library_facade.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final facade = AppServiceFactory.libraryFacade();
  await facade.init();
  runApp(MyApp(facade: facade));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.facade});

  final LibraryFacade facade;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Literatura Rusa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: facade.isAuthenticated()
          ? HomeScreen(
              facade: facade,
              title: 'Literatura Rusa',
            )
          : LoginScreen(facade: facade),
      routes: {
        '/login': (context) => LoginScreen(facade: facade),
        '/home': (context) => HomeScreen(
              facade: facade,
              title: 'Literatura Rusa',
            ),
      },
    );
  }
}