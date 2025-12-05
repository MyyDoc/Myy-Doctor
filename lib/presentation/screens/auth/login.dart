import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/selfie_screen.dart';
import 'package:myydoctor/presentation/widgets/auth/loginButton.dart';
import 'package:myydoctor/presentation/widgets/auth/icons.dart';
import 'package:myydoctor/presentation/widgets/auth/logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/auth/auth_repository.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController =
  TextEditingController();

  // State variables
  bool _obscurePassword = true;
  bool _obscureReEnterPassword = true;
  bool _isSignUpMode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
    });
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.cormorantGaramond(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.cormorantGaramond(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Success',
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.cormorantGaramond(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.cormorantGaramond(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show loading indicator
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please wait...',
                  style: GoogleFonts.cormorantGaramond(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Validate email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  // Handle Sign Up
  Future<void> _handleSignUp() async {
    // Validation
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email');
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    if (_fullNameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your full name');
      return;
    }

    if (_usernameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a username');
      return;
    }

    if (_usernameController.text.trim().length < 3) {
      _showErrorDialog('Username must be at least 3 characters');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorDialog('Please enter a password');
      return;
    }

    if (!_isValidPassword(_passwordController.text)) {
      _showErrorDialog('Password must be at least 6 characters');
      return;
    }

    if (_passwordController.text != _reEnterPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    final result = await _authService.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim().toLowerCase(),
    );

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context); // Close loading dialog

    if (result['success']) {
      // Navigate to selfie screen or next step
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SelfieScreen(),
        ),
      );
    } else {
      _showErrorDialog(result['message']);
    }

  }

  // Handle Login
  Future<void> _handleLogin() async {
    // Validation
    if (_usernameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your username or email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorDialog('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    // Determine if input is email or username
    String email = _usernameController.text.trim();

    // If not an email, we need to fetch the email from username
    // This requires a cloud function or additional query

    final result = await _authService.loginWithEmail(
      email: email,
      password: _passwordController.text,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context); // Close loading dialog

    if (result['success']) {
      await prefs.setBool('isLoggedIn', true);
      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Homescreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      _showErrorDialog(result['message']);
    }
  }

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    final result = await _authService.signInWithGoogle();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context); // Close loading dialog

    if (result['success']) {
      await prefs.setBool('isLoggedIn', true);
      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Homescreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      _showErrorDialog(result['message']);
    }
  }

  // Handle Facebook Sign In
  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    // Uncomment when AuthService is imported
    /*
    final result = await _authService.signInWithFacebook();

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context); // Close loading dialog

    if (result['success']) {
      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Homescreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      _showErrorDialog(result['message']);
    }
    */

    // Temporary navigation (remove when implementing auth)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
    _showSuccessDialog('Facebook Sign In - Coming Soon!');
  }

  // Handle Apple Sign In
  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    // Uncomment when AuthService is imported
    /*
    final result = await _authService.signInWithApple();

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context); // Close loading dialog

    if (result['success']) {
      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Homescreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      _showErrorDialog(result['message']);
    }
    */

    // Temporary navigation (remove when implementing auth)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
    _showSuccessDialog('Apple Sign In - Coming Soon!');
  }

  // Handle Forgot Password
  Future<void> _handleForgotPassword() async {
    final TextEditingController emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Reset Password',
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: GoogleFonts.cormorantGaramond(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: GoogleFonts.cormorantGaramond(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(
                    color: Color(0xFFD4AF37),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.cormorantGaramond(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();

              if (email.isEmpty) {
                Navigator.pop(dialogContext);
                if (!mounted) return;
                _showErrorDialog('Please enter your email');
                return;
              }

              if (!_isValidEmail(email)) {
                Navigator.pop(dialogContext);
                if (!mounted) return;
                _showErrorDialog('Please enter a valid email');
                return;
              }

              // Close the dialog first
              Navigator.pop(dialogContext);

              // Show loading dialog using the parent context
              if (!mounted) return;
              _showLoadingDialog();

              // Perform async operation
              final result = await _authService.resetPassword(email);

              // Check if still mounted before closing loading dialog
              if (!mounted) return;
              Navigator.pop(context); // Close loading dialog

              // Show result
              if (result['success']) {
                _showSuccessDialog(result['message']);
              } else {
                _showErrorDialog(result['message']);
              }
            },
            child: Text(
              'Send',
              style: GoogleFonts.cormorantGaramond(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDBF1F7), // light blue
              Color(0xFF89AEBA), // mid tone
              Color(0xFF172832), // dark navy
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              // Fixed logo section at the top
              Container(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: const AppLogo(),
              ),

              // Scrollable content section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Email Field (only for signup)
                      if (_isSignUpMode) ...[
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Full Name Field (only for signup)
                      if (_isSignUpMode) ...[
                        _buildTextField(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Username Field
                      _buildTextField(
                        controller: _usernameController,
                        hintText: _isSignUpMode ? 'Username' : 'Username or Email',
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      // Re-Enter Password Field (only for signup)
                      if (_isSignUpMode) ...[
                        _buildPasswordField(
                          controller: _reEnterPasswordController,
                          hintText: 'Re-Enter Password',
                          obscureText: _obscureReEnterPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureReEnterPassword =
                              !_obscureReEnterPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Service upload text or Terms for signup
                      if (_isSignUpMode)
                        _buildTermsText()
                      else
                        _buildServiceText(),

                      const SizedBox(height: 16),

                      // Login/Signup Button
                      LoginButton(
                        function: _isLoading
                            ? () {}
                            : () {
                          if (_isSignUpMode) {
                            _handleSignUp();
                          } else {
                            _handleLogin();
                          }
                        },
                        text: _isSignUpMode ? 'Sign Up' : 'Log In',
                      ),
                      const SizedBox(height: 24),

                      // Social Login Icons
                      SocialLoginButtons(
                        onGoogleTap: _isLoading ? () {} : _handleGoogleSignIn,
                        onFacebookTap: _isLoading ? () {} : _handleFacebookSignIn,
                        onAppleTap: _isLoading ? () {} : _handleAppleSignIn,
                      ),
                      const SizedBox(height: 16),

                      // Toggle between login and signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSignUpMode
                                ? "Already have an account? "
                                : "Don't Have an account? ",
                            style: GoogleFonts.cormorantGaramond(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : _toggleMode,
                            child: Text(
                              _isSignUpMode ? 'Log In' : 'Sign Up',
                              style: GoogleFonts.cormorantGaramond(
                                color: const Color(0xFFD4AF37),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password Link (only for login)
                      if (!_isSignUpMode)
                        GestureDetector(
                          onTap: _isLoading ? null : _handleForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.cormorantGaramond(
                              color: const Color(0xFFD4AF37),
                              fontSize: 15,
                            ),
                          ),
                        ),

                      // Add some bottom padding to ensure scrollability
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cormorantGaramond(
            fontSize: 16,
            color: Colors.black54,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cormorantGaramond(
            fontSize: 16,
            color: Colors.black54,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.cormorantGaramond(
          color: Colors.white70,
          fontSize: 15,
        ),
        children: [
          const TextSpan(
            text:
            'People who use our service may have uploaded\nyour contact information to Myydoctor. ',
          ),
          TextSpan(
            text: 'Learn More',
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFFD4AF37),
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.cormorantGaramond(
          color: Colors.white70,
          fontSize: 15,
        ),
        children: [
          const TextSpan(text: 'By signing up, you agree to our '),
          TextSpan(
            text: 'Terms',
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFFD4AF37),
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ',\n'),
          TextSpan(
            text: 'Privacy Policy',
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFFD4AF37),
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ', and '),
          TextSpan(
            text: 'Cookies Policy',
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFFD4AF37),
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}