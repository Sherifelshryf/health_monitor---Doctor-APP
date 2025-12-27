import 'package:flutter/material.dart';

void main() {
  runApp(const IconCreatorApp());
}

class IconCreatorApp extends StatelessWidget {
  const IconCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: const Color(0xFF0a2351), // Dark blue background
          child: const Center(
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 200,
            ),
          ),
        ),
      ),
    );
  }
} 