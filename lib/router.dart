import 'package:base_flutter_template/login_page.dart';
import 'package:base_flutter_template/main.dart';
import 'package:base_flutter_template/weekly_schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AuthService extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> authenticateWithBiometrics() async {
    try {
      // Check if device supports biometrics OR any device-level authentication
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        print('No authentication methods available');
        return false;
      }

      // Get available biometrics (optional - for debugging)
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');

      // Attempt authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Rebirth',
        biometricOnly: true,
      );

      if (didAuthenticate) {
        _isAuthenticated = true;
        notifyListeners();
      }

      return didAuthenticate;
    } on LocalAuthException catch (e) {
      print('Authentication error: ${e.code}');

      // Handle specific error cases
      switch (e.code) {
        case LocalAuthExceptionCode.noBiometricHardware:
          print('No biometric hardware available');
          break;
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricLockout:
          print('Too many failed attempts - locked out temporarily');
          break;
        default:
          print('Other authentication error');
      }
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }
}

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    // redirect: (context, state) {
    //   final isLoggedIn = authService.isAuthenticated;
    //   final isLoggingIn = state.matchedLocation == '/login';

    //   // Redirect to login if not authenticated
    //   if (!isLoggedIn && !isLoggingIn) {
    //     return '/login';
    //   }

    //   // Redirect to home if already authenticated and trying to go to login
    //   if (isLoggedIn && isLoggingIn) {
    //     return '/home_page';
    //   }

    //   return null;
    // },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(authService: authService),
      ),
      GoRoute(
        path: '/home_page',
        name: 'home',
        builder: (context, state) => const MyHomePage(),
      ),
      GoRoute(
        path: '/weekly-schedule',
        name: 'weekly-schedule',
        builder: (context, state) => const WeeklySchedulePage(),
      ),
      // GoRoute(
      //   path: '/todo-list',
      //   name: 'todo-list',
      //   builder: (context, state) => const TodoListPage(),
      // ),
      // GoRoute(
      //   path: '/shopping-list',
      //   name: 'shopping-list',
      //   builder: (context, state) => const ShoppingListPage(),
      // ),
      // GoRoute(
      //   path: '/car-maintenance',
      //   name: 'car-maintenance',
      //   builder: (context, state) => const CarMaintenancePage(),
      // ),
    ],
  );
}
