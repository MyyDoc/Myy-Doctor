
import 'package:flutter/material.dart';

class StoryCircleItem extends StatelessWidget {
  const StoryCircleItem({
    super.key,
    required this.textTheme,
    required this.index,
    required this.isFromProfile
  });

  final TextTheme textTheme;
  final int index;
  final bool isFromProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isFromProfile ?  Color(0xFFD4AF37) : Colors.redAccent,
            shape: BoxShape.circle,
          ),
          height: 80,
          width: 80,
          child: Padding(
            padding: EdgeInsets.all(3),
            child: CircleAvatar(
              child: isFromProfile ? Icon(Icons.lock_outline, color:  Color(0xFFD4AF37), size: 35,) : SizedBox(),
            ),
          ),
        ),
        Text(
          "name $index",
          style: textTheme.bodyMedium!.copyWith(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
