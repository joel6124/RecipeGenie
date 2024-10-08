import 'package:flutter/material.dart';
import 'package:recipe_genie/home_page.dart';
import 'db_helper.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RecipeDatabaseHelper _dbHelper = RecipeDatabaseHelper();
  bool _isRegistering = false;

  void _toggleForm() {
    setState(() {
      _isRegistering = !_isRegistering;
    });
  }

  void _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Username and password cannot be empty');
      return;
    }

    if (_isRegistering) {
      try {
        await _dbHelper.registerUser(username, password);
        _showMessage('User registered successfully');
        // Clear the text fields after successful registration
        _usernameController.clear();
        _passwordController.clear();
      } catch (e) {
        _showMessage('Registration failed: ${e.toString()}');
      }
    } else {
      try {
        final success = await _dbHelper.loginUser(username, password);
        if (success) {
          _showMessage('Login successful');
          // Clear the text fields after successful login
          _usernameController.clear();
          _passwordController.clear();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        } else {
          _showMessage('Login failed: Invalid credentials');
        }
      } catch (e) {
        _showMessage('Login failed: ${e.toString()}');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 218, 234, 236),
        appBar: AppBar(
          toolbarHeight: 60,
          title: Text(
            _isRegistering ? 'Register' : 'Login',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 35, 48),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
              ),
              ClipOval(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.local_dining,
                    color: const Color(0xFF002330),
                    size: 150,
                  ),
                ),
              )),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        suffixIcon: Icon(Icons.person_2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: Icon(Icons.password),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        _submit();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(255, 0, 35, 48),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRegistering ? 'Register' : 'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: _toggleForm,
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF002330), // Text color
                        ),
                        child: Text(
                          _isRegistering
                              ? 'Already have an account? Login'
                              : 'Create an account',
                          style: TextStyle(
                            color: const Color(0xFF002330),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
