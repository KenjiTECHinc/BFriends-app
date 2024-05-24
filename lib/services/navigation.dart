// ignore: dangling_library_doc_comments
////////////////////////////////////////
// According to Flutter.dev using go_router seems more beneficial for our app in the long-term.
// ref: https://docs.flutter.dev/ui/navigation
//
////////////////////////////////////////
//import 'dart:js';

import 'package:bfriends_app/pages/homepage.dart';
import 'package:bfriends_app/pages/signin_page.dart';
import 'package:bfriends_app/pages/signup_page.dart';
import 'package:bfriends_app/pages/welcome_page.dart';
import 'package:bfriends_app/services/navigation_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

//DO: setup routes
final routerConfig = GoRouter(
  routes: [
    GoRoute(
      path: '/welcome_page',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: WelcomeScreen(),
      ),
      routes: [
        GoRoute(
          path: 'signin',
          builder: (context, state) => const SignInScreen(),
          routes: signInRoute,
        ),
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignUpScreen(),
          routes: signUpRoute,
        )
      ],
    ),
    GoRoute(
      path: '/home_page',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: HomePage(
          selectedTabs: NavigationTabs.home,
        ),
      ),
    ),
    GoRoute(
        path: '/friends_page',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: HomePage(selectedTabs: NavigationTabs.friends),
            )),
    GoRoute(
        path: '/events_page',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: HomePage(selectedTabs: NavigationTabs.events),
            )),
    GoRoute(
        path: '/profile_page',
        pageBuilder: (context, state) => const NoTransitionPage<void>(
              child: HomePage(selectedTabs: NavigationTabs.profile),
            ))
  ],
  initialLocation: '/welcome_page',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final currentPath = state.uri.path;

    final user = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null;

    if (currentPath == '/') {
      return '/welcome_page';
    } else if (currentPath == '/home') {
      return '/home_page';
    } else if (currentPath == '/friends') {
      return '/friends_page';
    } else if (currentPath == '/events') {
      return '/events_page';
    } else if (currentPath == '/profile') {
      return '/profile_page';
    }
    // No redirection needed for other routes
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  void goHome({required NavigationTabs tab}) {
    /// navigate bottom bar ///
    _router.go('/${tab.name}');
  }

  void pushAuthOnPage(
      {required BuildContext context,
      required String destination,
      Object? extra}) {
    /// push account authentication process pages ///
    var path = _currentPath(context);
    try {
      _router.go('$path/$destination', extra: extra);
    } on Exception catch (e) {
      debugPrint('Cannot push $destination on the path: $path');
      debugPrint(e.toString());
    }
  }

  void popAuthOnPage({required BuildContext context}) {
    /// pop authentication process stack ///
    var path = _currentPath(context);
    switch (path) {
      case '/welcome_page/signin/recov_email/verify_email/reset_pass':
        _router.go('/welcome_page/signin');
        return;
      case '/welcome_page/signin':
        _router.go('/welcome_page/signup');
        return;
      case '/welcome_page/signup':
        _router.go('/welcome_page/signin');
        return;
    }
    throw Exception('Failed to pop stack from path: $path');
  }
}
