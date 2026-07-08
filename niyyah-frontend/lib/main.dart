// lib/main.dart

import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/goals_list_screen.dart';
import 'screens/goal_detail_screen.dart';
import 'screens/create_edit_goal_screen.dart';
import 'models/goal.dart';
import 'core/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  runApp(const NiyyahApp());
}

class NiyyahApp extends StatelessWidget {
  const NiyyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niyyah',
      debugShowCheckedModeBanner: false,
      theme: NiyyahTheme.themeData,
      // AuthGate is the first widget shown. It checks for a saved token.
      home: const AuthGate(),
      // Named routes for every screen.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/shell': (context) => const AppShell(),
        '/create': (context) => const CreateEditGoalScreen(),
      },
      // onGenerateRoute handles routes that need arguments (detail, edit).
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final goal = settings.arguments as Goal;
          return MaterialPageRoute(
            builder: (context) => GoalDetailScreen(goal: goal),
          );
        }
        if (settings.name == '/edit') {
          final goal = settings.arguments as Goal;
          return MaterialPageRoute(
            builder: (context) => CreateEditGoalScreen(goal: goal),
          );
        }
        return null;
      },
    );
  }
}

// ─────────────────────────────────────────────
// AUTH GATE
// Checks token on app launch. Shows a spinner
// while checking, then routes to the right place.
// ─────────────────────────────────────────────
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Instead of just checking if a token exists locally (which fails
    // on Flutter Web due to secure storage limitations), we verify
    // the token is actually valid by hitting the server.
    final user = await AuthService.getCurrentUser();

    if (!mounted) return;

    if (user != null) {
      // Server confirmed the token is valid → go to app
      Navigator.of(context).pushReplacementNamed('/shell');
    } else {
      // Server rejected or no token → go to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a plain spinner while the token check runs
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// APP SHELL
// The persistent bottom navigation bar wrapper.
// It keeps Home and My Goals alive while switching.
// ─────────────────────────────────────────────
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    GoalsListScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed('/create');
      return;
    }
    setState(() {
      _currentIndex = index == 0 ? 0 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              children: [
                // Home
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(0),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentIndex == 0
                              ? Iconsax.home_15
                              : Iconsax.home_1,
                          color: _currentIndex == 0
                              ? const Color(0xFF1A7A6E)
                              : const Color(0xFF999999),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Home',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _currentIndex == 0
                                ? const Color(0xFF1A7A6E)
                                : const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // FAB center
                GestureDetector(
                  onTap: () => _onTabTapped(1),
                  child: Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A7A6E),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x331A7A6E),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                // My Goals
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(2),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentIndex == 1
                              ? Iconsax.task_square5
                              : Iconsax.task_square,
                          color: _currentIndex == 1
                              ? const Color(0xFF1A7A6E)
                              : const Color(0xFF999999),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'My Goals',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _currentIndex == 1
                                ? const Color(0xFF1A7A6E)
                                : const Color(0xFF999999),
                          ),
                        ),
                      ],
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