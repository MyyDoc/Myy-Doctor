
import 'package:flutter/material.dart';

class SavedContents extends StatelessWidget {
  const SavedContents({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.8
      ),
      itemCount: 14, 
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.amber,
          ),
          child: Text("Item $index"),
        );
      },
    );
  }
}
