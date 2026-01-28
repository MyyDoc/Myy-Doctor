import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/widgets/verify_email_button.dart';
import 'package:myydoctor/presentation/screens/setting_options/verify_email/widgets/verify_email_textfield.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class ChangeEmailWidget extends StatefulWidget {
  final VoidCallback? onCancel;           // to go back to current email view
  final Function(String)? onEmailUpdated; // optional callback after success

  const ChangeEmailWidget({
    super.key,
    this.onCancel,
    this.onEmailUpdated,
  });

  @override
  State<ChangeEmailWidget> createState() => _ChangeEmailWidgetState();
}

class _ChangeEmailWidgetState extends State<ChangeEmailWidget> {
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  String? _currentEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentEmail();
  }

  Future<void> _loadCurrentEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentEmail = user.email ?? 'Not set';
      });
    }
  }

  Future<void> _changeEmail() async {
    final newEmail = _newEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (newEmail.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both fields');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(newEmail)) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Re-authenticate (required for updateEmail / verifyBeforeUpdateEmail)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Send verification to the NEW email
      await user.verifyBeforeUpdateEmail(newEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent to new address!\nPlease verify it to complete the change.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      _newEmailController.clear();
      _passwordController.clear();

      // Optional: notify parent or go back
      if (widget.onEmailUpdated != null) {
        widget.onEmailUpdated!(newEmail);
      } else {
        // Or just go back to current email view
        if (widget.onCancel != null) {
          widget.onCancel!();
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password':
          msg = 'Incorrect password';
          break;
        case 'requires-recent-login':
          msg = 'Please sign in again to perform this action';
          break;
        case 'email-already-in-use':
          msg = 'This email is already in use';
          break;
        case 'invalid-email':
          msg = 'Invalid email format';
          break;
        default:
          msg = e.message ?? 'An error occurred';
      }
      setState(() => _errorMessage = msg);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.amber.withOpacity(0.15),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This new email will become your login email after verification.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Current email
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current email address:',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _currentEmail ?? 'Loading...',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // New email field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New email address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              VerifyEmailTextfield(
                hintText: 'Enter new email',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Password field (for re-auth)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              VerifyEmailTextfield(
                hintText: 'Enter your password',
                isForPassword: true,
              ),
            ],
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],

        const SizedBox(height: 40),

        // Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel
              OutlinedButton(
                onPressed: widget.onCancel ?? () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.grey),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Cancel'),
              ),

              // Submit
              SizedBox(
                width: screenWidth * 0.5,
                child: VerifyEmailButton(
                  text: _isLoading ? 'Sending...' : 'Send Verification',
                  onPress: _isLoading ? null : _changeEmail,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}