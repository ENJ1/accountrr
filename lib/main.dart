import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Views/HomeScreen.dart';
import "Views/TransactionScreen.dart";
import 'package:flutter/services.dart';
import 'Views/EditTransactionScreen.dart';
import 'Views/HelpScreen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;

  runApp(const ProviderScope(child: MyApp()));
}

/// The route configuration.

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
          NavigationDestination(
              label: 'Transactions', icon: Icon(Icons.attach_money)),
          //NavigationDestination(
          //    label: 'Your Goals', icon: Icon(Icons.track_changes)),
        ],
        onDestinationSelected: _goBranch,
      ),
      floatingActionButton: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              context.push("/add_transaction");
            },
            label: const Text("Add Transaction"),
            icon: const Icon(Icons.add),
          ),
          FloatingActionButton(
              onPressed: () {
                context.push("/help");
              },
              child: const Icon(Icons.help))
        ],
      ),
    );
  }
}

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');

final _routerConfig = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // the UI shell
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
              routes: const [],
            ),
          ],
        ),
        // second branch (B)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/transactions',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TransactionScreen(),
              ),
              routes: const [],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            // top route inside branch
            GoRoute(
              path: '/goals',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TransactionScreen(),
              ),
              routes: const [],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add_transaction',
      builder: (context, state) => EditTransactionScreen(),
    ),
    GoRoute(
      path: '/edit_transaction',
      builder: (context, state) => EditTransactionScreen(
          id: int.parse(state.uri.queryParameters['id']!)),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent, // Color for Android
        statusBarBrightness:
            Brightness.dark // Dark == white status bar -- for IOS.
        ));

    return Consumer(
        builder: (context, ref, child) => MaterialApp.router(
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.pink, brightness: Brightness.light)),
            routerConfig: _routerConfig));
  }
}
