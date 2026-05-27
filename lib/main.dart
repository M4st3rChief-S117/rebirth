// main.dart
import 'package:base_flutter_template/app_colors.dart';
import 'package:base_flutter_template/router.dart';
import 'package:base_flutter_template/shared_menu_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'animated_bubble_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyAppView(),
    );
  }
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rebirth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: createRouter(
        Provider.of<AuthService>(context, listen: false),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBubbleMenu(
      config: BubbleMenuConfig(
        mainBubbleColor: Colors.teal,
        menuRadius: 150,
        mainBubbleSize: 70,
        menuItemSize: 55,
        animationCurve: Curves.elasticOut,
        closeOnItemTap: true,
      ),
      items: getSharedMenuItems(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rebirth'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.teal.shade50, Colors.white],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 80, color: Colors.teal.shade300),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to Rebirth',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap the bubble below to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.opaque(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '4 menus available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.teal.shade600,
                      fontWeight: FontWeight.w500,
                    ),
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
