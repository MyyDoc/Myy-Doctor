import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final double? fontSize;
  final String? imagePath;
  final String logoText;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double borderWidth;

  const AppLogo({
    super.key,
    this.width = 160,
    this.height = 160,
    this.fontSize = 18,
    this.imagePath = 'assets/images/3172471a0d8a9cd80d4a843e30aa11563af1fced (1).png',
    this.logoText = 'MY DOCTOR',
    this.borderColor = const Color(0xFFD4AF37), // Gold
    this.backgroundColor = const Color(0xFF172832), // Dark navy
    this.textColor = const Color(0xFFD4AF37), // Gold
    this.borderRadius = 30,
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Stack(
        children: [
          // Background Image
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - borderWidth),
              child: Image.asset(
                imagePath!,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.medical_services,
                      color: borderColor,
                      size: (width! * 0.375), // Proportional icon size
                    ),
                  );
                },
              ),
            ),
          
          // Logo Text Overlay
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                logoText,
                style: GoogleFonts.cormorantGaramond(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}