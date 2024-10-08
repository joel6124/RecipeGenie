import 'package:flutter/material.dart';
import 'package:recipe_genie/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        // home: const MyHomePage(),
        home: AuthenticationPage()
        // home: GenerateRecipeScreen(),
        );
  }
}

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status when the widget is first created
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? const MyHomePage() : AuthPage();
  }
}
