import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Manager',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        hintColor: Colors.tealAccent,
      ),
      home: HomeScreen(),
    );
  }
}
