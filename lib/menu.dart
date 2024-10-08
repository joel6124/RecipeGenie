import 'package:flutter/material.dart';
import 'package:recipe_genie/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMenu extends StatelessWidget {
  final String username;

  const UserMenu({
    Key? key,
    required this.username,
  }) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Clear login state

    // Navigate to login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // backgroundColor: const Color(0xFFD3F5F9),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: ClipOval(
                child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), color: Colors.white),
              child: Icon(
                Icons.person,
                color: const Color(0xFF002330),
                size: 60,
              ),
            )),
            accountName: Text(
              username.toUpperCase(),
              style: const TextStyle(
                fontSize: 25, // Increased font size
                color: Color(0xFFD3F5F9),
                fontWeight: FontWeight.bold,
              ),
            ),
            // accountName: Column(
            //   children: [
            //     const Icon(
            //       Icons.person,
            //       color: Color(0xFFD3F5F9),
            //       size: 50, // Increased size
            //     ),
            //     const SizedBox(width: 15),
            //     Expanded(
            //       child: Text(
            //         username.toUpperCase(),
            //         style: const TextStyle(
            //           fontSize: 34, // Increased font size
            //           color: Color(0xFFD3F5F9),
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            decoration: BoxDecoration(
              color: const Color(0xFF002330),
            ),
            accountEmail: null,
          ),
          ListTile(
            leading: Icon(
              Icons.food_bank,
              size: 30,
              color: Colors.orange[900],
            ),
            title: const Text(
              'Add Recipe',
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // Handle navigation for adding a recipe
            },
          ),
          const Divider(),
          ListTile(
            leading:
                Icon(Icons.logout_rounded, size: 30, color: Colors.orange[900]),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _logout(context),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
