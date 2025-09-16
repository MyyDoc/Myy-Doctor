import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/selfie_screen.dart';
import 'package:myydoctor/presentation/widgets/auth/loginButton.dart';
import 'package:myydoctor/presentation/widgets/auth/icons.dart';
import 'package:myydoctor/presentation/widgets/auth/logo.dart';

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
  final TextEditingController _reEnterPasswordController =
      TextEditingController();

  // State variables
  bool _obscurePassword = true;
  bool _obscureReEnterPassword = true;
  bool _isSignUpMode = false; // This toggles between login and signup

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
                        hintText: 'Username',
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
                        function: () {
                          if (_isSignUpMode) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SelfieScreen(),));
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Homescreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          }
                        },
                        text: _isSignUpMode ? 'Sign Up' : 'Log In',
                      ),
                      const SizedBox(height: 24),

                      // Social Login Icons
                      SocialLoginButtons(
                        onGoogleTap: () {
                          print('Google login tapped');
                        },
                        onFacebookTap: () {
                          print('Facebook login tapped');
                        },
                        onAppleTap: () {
                          print('Apple login tapped');
                        },
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

                      // Forgot Password Link (only for login)
                      if (!_isSignUpMode)
                        GestureDetector(
                          onTap: () {
                            // Navigate to forgot password
                          },
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