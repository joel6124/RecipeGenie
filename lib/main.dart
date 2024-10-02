import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Gemini API
  Gemini.init(apiKey: 'AIzaSyDmnwqaXpVPdMtl8zWa9WxpNV0gbule-Wo');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Genie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const MyHomePage(),
      // home: GenerateRecipeScreen(),
    );
  }
}
