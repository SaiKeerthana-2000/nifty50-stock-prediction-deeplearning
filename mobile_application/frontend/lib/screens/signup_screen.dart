import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart'; // Import Login Screen
import 'welcome_screen.dart'; // Import WelcomeScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _signUpUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String username = _usernameController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    bool isSignedUp = await _authService.signUp(
      name,
      email,
      username,
      phone,
      password,
    );

    if (isSignedUp) {
      debugPrint("✅ Signup successful! Navigating to TermsScreen...");
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/terms');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User already exists!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ Extends body behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ Transparent AppBar
        elevation: 0, // ✅ Removes AppBar shadow
        automaticallyImplyLeading: false, // No default back button
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // White back icon
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const WelcomeScreen(),
              ), // Navigate to WelcomeScreen
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // ✅ Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/background9.jpg',
                ), // Same background as WelcomeScreen
                fit: BoxFit.cover, // Cover entire screen
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 10, // Add elevation for the card
                  color: Colors.white.withOpacity(1), // Set transparency here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      16.0,
                    ), // Rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Full Name TextField
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                        ),
                        const SizedBox(height: 10),

                        // Email TextField
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                        ),
                        const SizedBox(height: 10),

                        // Username TextField
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                        ),
                        const SizedBox(height: 10),

                        // Phone Number TextField
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 10),

                        // Password TextField with Eye Icon
                        _buildPasswordTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: !_isPasswordVisible,
                          onEyePressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        // Confirm Password TextField with Eye Icon
                        _buildPasswordTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          obscureText: !_isConfirmPasswordVisible,
                          onEyePressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Sign Up Button
                        ElevatedButton(
                          onPressed: _signUpUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors
                                    .teal, // Same button color as WelcomeScreen
                            minimumSize: const Size(150, 40),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Navigate to Login Screen
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Already have an account? Log in",
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build text fields with a frame and shadow
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  // Method to build password text fields with an eye icon to toggle visibility
  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onEyePressed,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onEyePressed,
        ),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
}
