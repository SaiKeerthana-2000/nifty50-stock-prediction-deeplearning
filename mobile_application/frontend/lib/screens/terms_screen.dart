import 'package:flutter/material.dart';
import 'home_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Extends body behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ Transparent AppBar
        elevation: 0, // ✅ Removes AppBar shadow
        automaticallyImplyLeading: true, // Keeps the back arrow
        iconTheme: const IconThemeData(
          color: Colors.white, // White back button for visibility
        ),
      ),
      body: Stack(
        children: [
          // ✅ Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background9.jpg'), // Same background
                fit: BoxFit.cover, // Cover entire screen
              ),
            ),
          ),
          // ✅ Main content below AppBar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Text color for visibility
                          ),
                          children: [
                            TextSpan(
                              text:
                                  "By using the Stock Prediction App, you agree to the following:\n\n",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  "The predictions are generated using deep learning techniques with historical stock data and market sentiment. "
                                  "They are for educational purposes only and should not be relied upon for investment decisions.\n\n"
                                  "We collect and process your data as described in our Privacy Policy. By using the app, you consent to the collection and use of your data.\n\n"
                                  "While we strive for accuracy, market conditions are unpredictable, and results may vary.\n\n"
                                  "The app is offered without any implied or expressed warranties and we are not liable for any financial losses or damages from its use or reliance on predictions.\n\n"
                                  "You are responsible for maintaining the confidentiality of your account credentials. We are not liable for unauthorized access.\n\n"
                                  "By using this app, you acknowledge and accept these terms.",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreed,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreed = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "I agree to the Terms & Conditions.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        _agreed
                            ? () {
                              debugPrint(
                                "✅ Terms accepted! Navigating to HomeScreen...",
                              );
                              if (mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Button color consistency
                      minimumSize: const Size(150, 40),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
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
