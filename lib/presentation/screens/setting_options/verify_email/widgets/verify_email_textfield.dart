import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class VerifyEmailTextfield extends StatefulWidget {
  final String hintText;
  final bool isForPassword;

  const VerifyEmailTextfield({
    super.key,
    required this.hintText,
    this.isForPassword = false,
  });

  @override
  State<VerifyEmailTextfield> createState() => _VerifyEmailTextfieldState();
}

class _VerifyEmailTextfieldState extends State<VerifyEmailTextfield> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.isForPassword ? _obscureText : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        fillColor: AppColors.white,
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.isForPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
