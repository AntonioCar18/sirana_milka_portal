import 'package:flutter/material.dart';
import 'package:sirana_milka/screens/login_screen.dart';
import 'package:sirana_milka/screens/dashboard.dart';
import 'package:sirana_milka/screens/storage.dart';
import 'package:sirana_milka/screens/partners.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'login': (context) => LoginScreen(),
        'dashboard': (context) => Dashboard(),
        'storage': (context) => Storage(),
        'partners': (context) => Partners(),
      },
    );
  }
}