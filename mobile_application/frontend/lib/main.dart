import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/prediction_screen.dart';
import 'screens/past_predictions_screen.dart';
import 'screens/news_screen.dart';
import 'screens/fgi_data_screen.dart';
import 'screens/fgi_tomorrow_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Predictor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:
          const WelcomeScreen(), // ✅ Changed from AuthWrapper to WelcomeScreen
      routes: {
        '/home': (context) => const HomeScreen(),
        '/prediction': (context) => const PredictionScreen(),
        '/past_predictions': (context) => const PastPredictionsScreen(),
        '/news': (context) => const NewsScreen(),
        '/fgi_data': (context) => const FgiDataScreen(),
        '/fgi_tomorrow': (context) => const FgiTomorrowScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/terms': (context) => const TermsScreen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}

// ✅ AuthWrapper is now the main entry point for login check
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print("⏳ Checking login status...");
      bool isLoggedIn = await AuthService().isUserLoggedIn();
      print("🔍 User is logged in: $isLoggedIn");

      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      print("❌ Error during initialization: $e\n$stacktrace");
      if (mounted) {
        setState(() {
          _isLoading = false; // Avoid infinite loading in case of errors
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ Navigate based on login status
    return _isLoggedIn ? const HomeScreen() : const WelcomeScreen();
  }
}
