import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/home/feed_container_item.dart';

class SavedFeedsDetailedScreen extends StatefulWidget {
  const SavedFeedsDetailedScreen({super.key});

  @override
  State<SavedFeedsDetailedScreen> createState() =>
      _SavedFeedsDetailedScreenState();
}

class _SavedFeedsDetailedScreenState extends State<SavedFeedsDetailedScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ThemeData
    final textTheme = Theme.of(context).textTheme; // TextTheme
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: Colors.white,)),
      automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1F323C),
        title: Text(
          "Saved",
          style: textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1F323C), // Top
                Color(0xFF000000), // Bottom
              ],
            ),
          ),
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 10,
            separatorBuilder: (context, index) => const SizedBox(height: 30),
            itemBuilder:
                (context, index) => FeedContainerItem(textTheme: textTheme),
          ),
        ),
      ),
    );
  }
}
