import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'screens/jobs_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/add_job_screen.dart';
import 'screens/add_contact_screen.dart';
import 'screens/contact_detail_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider<User?>(create: (context) => context.read<AuthService>().authStateChanges, initialData: null,)
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.blue;

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.blue.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final user = Provider.of<User?>(context);

        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const AuthScreen(),
            ),
            GoRoute(
              path: '/add-job',
              builder: (context, state) => const AddJobScreen(),
            ),
            GoRoute(
              path: '/add-contact',
              builder: (context, state) => const AddContactScreen(),
            ),
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) {
                return ScaffoldWithNavBar(navigationShell: navigationShell);
              },
              branches: [
                 StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/home',
                      builder: (context, state) => const HomeScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/jobs',
                      builder: (context, state) => const JobsScreen(),
                      routes: [
                        GoRoute(
                          path: 'detail/:id',
                          builder: (context, state) {
                            final String id = state.pathParameters['id']!;
                            return JobDetailScreen(jobId: id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/calendar',
                      builder: (context, state) => const CalendarScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/contacts',
                      builder: (context, state) => const ContactsScreen(),
                      routes: [
                        GoRoute(
                          path: 'detail/:id',
                          builder: (context, state) {
                            final String id = state.pathParameters['id']!;
                            return ContactDetailScreen(contactId: id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
          redirect: (BuildContext context, GoRouterState state) {
            final bool loggedIn = user != null;
            final bool loggingIn = state.matchedLocation == '/login';

            if (!loggedIn) {
              return loggingIn ? null : '/login';
            }

            if (loggingIn) {
              return '/home';
            }

            return null;
          },
        );

        return MaterialApp.router(
          title: 'IT Service App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
       appBar: AppBar(
        title: Text(_getTitleForIndex(navigationShell.currentIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          )
        ],
      ),
      body: navigationShell,
       bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
           NavigationDestination(label: 'Home', icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home)),
          NavigationDestination(label: 'Jobs', icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work)),
          NavigationDestination(
            label: 'Calendar',
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
          ),
          NavigationDestination(label: 'Contacts', icon: Icon(Icons.contacts_outlined), selectedIcon: Icon(Icons.contacts)),
        ],
      ),
    );
  }
  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Jobs';
      case 2:
        return 'Calendar';
      case 3:
        return 'Contacts';
      default:
        return 'IT Service App';
    }
  }

}
