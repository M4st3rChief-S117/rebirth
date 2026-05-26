import 'package:base_flutter_template/api_service.dart';
import 'package:base_flutter_template/login_page.dart';
import 'package:base_flutter_template/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter createRouter(ApiService authService) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authService.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // Redirect to home if already authenticated and trying to go to login
      if (isLoggedIn && isLoggingIn) {
        return '/home_page';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home_page',
        name: 'home',
        builder: (context, state) => const MyHomePage(),
      ),
    ],
  );
}
