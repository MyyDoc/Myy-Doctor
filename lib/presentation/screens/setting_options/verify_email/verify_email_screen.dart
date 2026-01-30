import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/widgets/change_email_widget.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/widgets/current_email_widget.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

import '../../../../core/loader/loader.dart'; // Assuming this has your colors

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isVerified = false;
  Timer? _verificationTimer;
  bool _showChangeEmail = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _currentUser!.reload();
      _currentUser = FirebaseAuth.instance.currentUser;
      setState(() {
        _isVerified = _currentUser!.emailVerified;
      });

      if (!_isVerified) {
        _startVerificationPolling();
      }
    }
    setState(() => _isLoading = false);
  }

  void _startVerificationPolling() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentUser == null) {
        timer.cancel();
        return;
      }
      await _currentUser!.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        setState(() {
          _isVerified = true;
        });
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email verified successfully!")),
        );
        // Optional: pop screen or refresh parent
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (_currentUser == null) return;
    try {
      await _currentUser!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent! Check your inbox/spam.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: MyyDocLoader()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("No user signed in")),
      );
    }

    final email = _currentUser!.email ?? "No email set";

    return Scaffold(
      backgroundColor: AppColors.scaffoldWhite,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios, color: Colors.white,)),
        centerTitle: true,
        title: Text(
          'Verify Email',
          style: TextStyle(color: AppColors.caramel, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _showChangeEmail
              ? ChangeEmailWidget(
            onCancel: () {
              setState(() => _showChangeEmail = false);
            },
            onEmailUpdated: (newEmail) {
              setState(() {
                _showChangeEmail = false;
              });
              _loadUser(); // Refresh after change
            },
          )
              : CurrentEmailWidget(
            email: email,
            isVerified: _isVerified,
            onResend: _sendVerificationEmail,
            onChangeEmail: () {
              setState(() => _showChangeEmail = true);
            },
          ),
        ),
      ),
    );
  }
}