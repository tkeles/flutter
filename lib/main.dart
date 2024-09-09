import 'package:flutter/material.dart';
import 'package:ngen_delivex/screens/HomeScreen.dart';
import 'screens/LoginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      // Yönlendirme ve diğer sayfalar için route tanımlamaları yapabilirsiniz
      routes: {
        '/home': (context) => const HomeScreen(username: 'default_username'), // HomeScreen de oluşturmalısınız
      },
    );
  }
}