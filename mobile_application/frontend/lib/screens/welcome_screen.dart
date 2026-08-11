import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double titleTopPosition = 150.0; // ✅ Initial vertical position for title

  @override
  Widget build(BuildContext context) {
    // ✅ Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Extends body behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ Transparent AppBar
        elevation: 0, // ✅ Removes shadow from AppBar
        automaticallyImplyLeading: false, // No back arrow
        actions: [
          // Sign Up Button in AppBar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // ✅ Sign Up button color
            ),
            onPressed: () {
              print("Navigating to SignUpScreen...");
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.white, // Button text color
              ),
            ),
          ),
          const SizedBox(width: 10), // Space between buttons
          // Login Button in AppBar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // ✅ Login button color
            ),
            onPressed: () {
              print("Navigating to LoginScreen...");
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.white, // Button text color
              ),
            ),
          ),
          const SizedBox(width: 10), // Space at the end
        ],
      ),
      body: Stack(
        children: [
          // ✅ Full-Screen Background Image with Fixed Size
          SizedBox(
            width: screenWidth, // ✅ Matches screen width
            height: screenHeight, // ✅ Matches screen height
            child: Image.asset(
              'assets/background3.jpg', // ✅ Background path
              fit: BoxFit.fill, // ✅ Fills the screen with stretching if needed
            ),
          ),

          // ✅ Title with Icon and Adjustable Position
          Positioned(
            top: titleTopPosition,
            left: 0,
            right: 0,
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to NiftySense 🚀',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Ensures text is visible
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
