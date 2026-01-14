import 'package:checklist/view/cadastro.dart';
import 'package:checklist/view/home.dart';
import 'package:checklist/widget/WidgetBody.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}