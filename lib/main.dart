import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
import 'screens/event/event_list_screen.dart';
import 'screens/event/event_detail_screen.dart';
import 'screens/event/my_events_screen.dart';
import 'screens/admin/admin_event_list_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_user_list_screen.dart';
import 'screens/event/event_create_screen.dart';
import 'models/event_model.dart';
import 'screens/profile_screen.dart' as profile_screen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Registration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF6C4E31), // #6C4E31
          onPrimary: Colors.white,
          secondary: const Color(0xFFFFEAC5), // #FFEAC5
          onSecondary: Colors.black,
          background: const Color(0xFFFFDBB5), // #FFDBB5
          onBackground: Colors.black,
          surface: const Color(0xFFFFEAC5), // #FFEAC5
          onSurface: Colors.black,
          error: const Color(0xFF603F26), // #603F26
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFDBB5), // #FFDBB5
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C4E31), // #6C4E31
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C4E31), // #6C4E31
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF603F26), // #603F26
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFEAC5), // #FFEAC5
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainApp(),  // Change from HomeScreen to MainApp
        '/events': (context) => const EventListScreen(),
        '/my-events': (context) => const MyEventsScreen(),
        '/admin-events': (context) => const AdminEventListScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-users': (context) => const AdminUserListScreen(),
        '/event-create': (context) => const EventCreateScreen(),
        '/profile': (context) => const profile_screen.ProfileScreen(),
        '/event-list': (context) => const EventListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/event-detail') {
          final args = settings.arguments;
          if (args is EventModel) {
            return MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: args),
            );
          }
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Invalid event argument')),
            ),
          );
        }
        return null;
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  late Stream<UserModel?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = _authService.authStateChanges;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const MainApp();  // Change from HomeScreen to MainApp
        }
        return const LoginScreen();
      },
    );
  }
}
