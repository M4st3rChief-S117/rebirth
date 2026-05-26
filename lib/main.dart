// main.dart
import 'package:base_flutter_template/api_service.dart';
import 'package:base_flutter_template/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      create: (context) => ApiService(),
      child: const MyAppView(),
    );
  }
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: createRouter(
        Provider.of<ApiService>(context, listen: false),
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
        mainBubbleColor: Colors.deepPurple,
        menuRadius: 150, // Increased radius
        mainBubbleSize: 70,
        menuItemSize: 55,
        animationCurve: Curves.elasticOut,
        closeOnItemTap: true,
      ),
      items: [
        AnimatedBubbleItem(
          icon: Icons.home,
          label: 'Home',
          color: Colors.red,
          onTap: () {
            print('Home tapped');
            // Add navigation logic here
          },
        ),
        AnimatedBubbleItem(
          icon: Icons.thunderstorm,
          label: 'Elettricisti',
          color: Colors.blue,
          onTap: () {
            context.go('elettricisti');
          },
        ),
        AnimatedBubbleItem(
          icon: Icons.settings,
          label: 'Settings',
          color: Colors.green,
          onTap: () {
            print('Settings tapped');
          },
        ),
        AnimatedBubbleItem(
          icon: Icons.favorite,
          label: 'Favorites',
          color: Colors.pink,
          onTap: () {
            print('Favorites tapped');
          },
        ),
        AnimatedBubbleItem(
          icon: Icons.notifications,
          label: 'Alerts',
          color: Colors.orange,
          onTap: () {
            print('Notifications tapped');
          },
        ),
        AnimatedBubbleItem(
          icon: Icons.shopping_cart,
          label: 'Cart',
          color: Colors.teal,
          onTap: () {
            print('Cart tapped');
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Animated Bubble Menu'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade50, Colors.white],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 80,
                  color: Colors.deepPurple.shade200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tap the bubble below!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$AnimatedBubbleMenu items available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple.shade400,
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
