import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onAppleTap;

  const SocialLoginButtons({
    super.key,
    this.onGoogleTap,
    this.onFacebookTap,
    this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          onTap: onGoogleTap ?? () {},
          child: _buildGoogleIcon(),
        ),
        const SizedBox(width: 20),
        _SocialButton(
          onTap: onFacebookTap ?? () {},
          child: const Icon(
            Icons.facebook,
            color: Colors.blue,
            size: 24,
          ),
        ),
        const SizedBox(width: 20),
        _SocialButton(
          onTap: onAppleTap ?? () {},
          child: const Icon(
            Icons.apple,
            color: Colors.black,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Image.asset(
      'assets/images/googleLogo.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          FontAwesomeIcons.google,
          color: Colors.red,
          size: 24,
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}