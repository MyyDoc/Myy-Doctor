import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyyDocLoader extends StatelessWidget {
  const MyyDocLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(child: SpinKitThreeBounce(color: Colors.amberAccent, size: 30)),
    );
  }
}
