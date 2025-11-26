import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myydoctor/services/authentication/auth_service.dart';
import 'package:myydoctor/presentation/widgets/auth/loginButton.dart';
import 'package:myydoctor/presentation/widgets/auth/icons.dart';
import 'package:myydoctor/presentation/widgets/auth/logo.dart';
import 'package:myydoctor/presentation/screens/home/homescreen.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  bool isLogin = true;
  bool isLoading = false;

  final AuthService _authService = AuthService();

  final TextEditingController loginInputController = TextEditingController(); // email or username
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // LOGIN HANDLER
  Future<void> handleLogin() async {
    setState(() => isLoading = true);

    String loginInput = loginInputController.text.trim();
    String password = passwordController.text;

    if (loginInput.isEmpty || password.isEmpty) {
      setState(() => isLoading = false);
      return showError("Enter Email/Username & Password");
    }

    String? result = await _authService.signIn(
      loginInput: loginInput,
      password: password,
    );

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Homescreen()),
      );
    } else {
      showError(result);
    }
  }

  // SIGNUP HANDLER
 Future<void> handleSignup() async {
  setState(() => isLoading = true);

  String email = signupEmailController.text.trim();
  String password = passwordController.text;
  String fullName = fullNameController.text.trim();
  String username = usernameController.text.trim();

  if (email.isEmpty || password.isEmpty || fullName.isEmpty || username.isEmpty) {
    setState(() => isLoading = false);
    return showError("All fields are required");
  }

  String? result = await _authService.signUp(
    email: email,
    password: password,
    fullName: fullName,
    username: username,
  );

  setState(() => isLoading = false);

  if (result == null) {
    setState(() => isLogin = true); // go to login page
  } else {
    showError(result);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF172832),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const AppLogo(),

                const SizedBox(height: 40),

                Text(
                  isLogin ? "LOGIN" : "SIGN UP",
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                if (isLogin) buildLoginUI() else buildSignupUI(),

                const SizedBox(height: 20),

                SocialLoginButtons(
                  onGoogleTap: () {},
                  onFacebookTap: () {},
                  onAppleTap: () {},
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // LOGIN UI
  Widget buildLoginUI() {
    return Column(
      children: [
        TextField(
          controller: loginInputController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Email or Username",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Password",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 30),

        LoginButton(
          text: isLoading ? "Please wait..." : "Login",
          function: isLoading ? () {} : handleLogin,
        ),
      ],
    );
  }

  // SIGNUP UI
  Widget buildSignupUI() {
    return Column(
      children: [
        TextField(
          controller: fullNameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Full Name",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Username",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: signupEmailController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Email",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Password",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 30),

        LoginButton(
          text: isLoading ? "Please wait..." : "Create Account",
          function: isLoading ? () {} : handleSignup,
        ),
      ],
    );
  }
}
