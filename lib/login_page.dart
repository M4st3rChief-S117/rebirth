import 'package:base_flutter_template/app_colors.dart';
import 'package:base_flutter_template/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  final AuthService authService;

  const LoginPage({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade900, Colors.teal.shade300],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 120,
                  color: Colors.white.opaque(0.9),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Rebirth',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your personal organization companion',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 60),
                ElevatedButton.icon(
                  onPressed: () async {
                    // final success = await authService
                    //     .authenticateWithBiometrics();
                    context.go('/home_page');
                    // if (success && context.mounted) {
                    //   context.go('/home_page');
                    // } else if (context.mounted) {
                    //   // Show error message
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text(
                    //         'Authentication failed. Please try again.',
                    //       ),
                    //       backgroundColor: Colors.red,
                    //     ),
                    //   );
                    // }
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text(
                    'Login with Fingerprint',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
