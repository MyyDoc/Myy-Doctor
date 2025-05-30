
import 'package:flutter/material.dart';

class StoryCircleItem extends StatelessWidget {
  const StoryCircleItem({
    super.key,
    required this.textTheme,
    required this.index
  });

  final TextTheme textTheme;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          height: 80,
          width: 80,
          child: Padding(
            padding: EdgeInsets.all(3),
            child: CircleAvatar(),
          ),
        ),
        Text(
          "name $index",
          style: textTheme.bodyMedium!.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
