import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/selfie_screen.dart';
import 'package:myydoctor/presentation/widgets/auth/loginButton.dart';
import 'package:myydoctor/presentation/widgets/auth/icons.dart';
import 'package:myydoctor/presentation/widgets/auth/logo.dart';
import 'package:myydoctor/services/authentication/apple_auth_service.dart';
import 'package:myydoctor/services/authentication/auth_service.dart';
import 'package:myydoctor/services/authentication/facebook_auth_service.dart';
import 'package:myydoctor/services/authentication/google_auth_service.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();

  // Service classes
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();
  final AppleAuthService _appleAuthService = AppleAuthService();

  // State variables
  bool _obscurePassword = true;
  bool _obscureReEnterPassword = true;
  bool _isSignUpMode = false; // This toggles between login and signup
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

  Future<void> _showErrorDialog(String message) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLoginSignUp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    String? result;
    if (_isSignUpMode) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final rePassword = _reEnterPasswordController.text;

      if (email.isEmpty ||
          _fullNameController.text.trim().isEmpty ||
          _usernameController.text.trim().isEmpty ||
          password.isEmpty ||
          rePassword.isEmpty) {
        setState(() => _isLoading = false);
        _showErrorDialog('Please fill all the fields.');
        return;
      }
      if (password != rePassword) {
        setState(() => _isLoading = false);
        _showErrorDialog('Passwords do not match.');
        return;
      }
      result = await _authService.signUp(email: email, password: password);
      setState(() => _isLoading = false);
      if (result == null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SelfieScreen()));
      } else {
        _showErrorDialog(result);
      }
    } else {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      if (username.isEmpty || password.isEmpty) {
        setState(() => _isLoading = false);
        _showErrorDialog('Please enter username and password.');
        return;
      }
      result = await _authService.signIn(email: username, password: password);
      setState(() => _isLoading = false);
      if (result == null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Homescreen()), (route) => false);
      } else {
        _showErrorDialog(result);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final result = await _googleAuthService.signInWithGoogle();
    setState(() => _isLoading = false);
    if (result == null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Homescreen()), (route) => false);
    } else {
      _showErrorDialog(result);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _isLoading = true);
    final result = await _facebookAuthService.signInWithFacebook();
    setState(() => _isLoading = false);
    if (result == null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Homescreen()), (route) => false);
    } else {
      _showErrorDialog(result);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    final result = await _appleAuthService.signInWithApple();
    setState(() => _isLoading = false);
    if (result == null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Homescreen()), (route) => false);
    } else {
      _showErrorDialog(result);
    }
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
              Color(0xFFDBF1F7),
              Color(0xFF89AEBA),
              Color(0xFF172832),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Container(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: const AppLogo(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      if (_isSignUpMode) ...[
                        _buildTextField(controller: _emailController, hintText: 'Email Address'),
                        const SizedBox(height: 14),
                        _buildTextField(controller: _fullNameController, hintText: 'Full Name'),
                        const SizedBox(height: 14),
                      ],
                      _buildTextField(controller: _usernameController, hintText: 'Username'),
                      const SizedBox(height: 14),
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      const SizedBox(height: 14),
                      if (_isSignUpMode) ...[
                        _buildPasswordField(
                          controller: _reEnterPasswordController,
                          hintText: 'Re-Enter Password',
                          obscureText: _obscureReEnterPassword,
                          onToggleVisibility: () {
                            setState(() =>
                                _obscureReEnterPassword = !_obscureReEnterPassword);
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (_isSignUpMode)
                        _buildTermsText()
                      else
                        _buildServiceText(),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : LoginButton(
                              function: _handleLoginSignUp,
                              text: _isSignUpMode ? 'Sign Up' : 'Log In',
                            ),
                      const SizedBox(height: 24),
                      SocialLoginButtons(
                        onGoogleTap: _handleGoogleSignIn,
                        onFacebookTap: _handleFacebookSignIn,
                        onAppleTap: _handleAppleSignIn,
                      ),
                      const SizedBox(height: 16),
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
                            onTap: _toggleMode,
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
                      if (!_isSignUpMode)
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement forgot password
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.cormorantGaramond(
                              color: const Color(0xFFD4AF37),
                              fontSize: 15,
                            ),
                          ),
                        ),
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
  }) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
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
