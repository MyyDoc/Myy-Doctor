import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/home/feed_container_item.dart';
import 'package:myydoctor/presentation/widgets/home/story_circle.dart';

class HomescreenBody extends StatefulWidget {
  const HomescreenBody({super.key});

  @override
  State<HomescreenBody> createState() => _HomescreenBodyState();
}

class _HomescreenBodyState extends State<HomescreenBody> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ThemeData
    final textTheme = Theme.of(context).textTheme; // TextTheme

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1F323C),
        title: Text(
          "MyyDoctor",
          style: textTheme.displaySmall!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(Icons.message_outlined, color: Colors.white, size: 30),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      height: 100,
                      child: ListView.separated(
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 10),
                        scrollDirection: Axis.horizontal,
                        itemBuilder:
                            (context, index) => StoryCircleItem(
                              isFromProfile: false,
                              textTheme: textTheme,
                              index: index,
                            ),
                        itemCount: 10,
                      ),
                    ),
                  ),
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 10,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 30),
                    itemBuilder:
                        (context, index) =>
                            FeedContainerItem(textTheme: textTheme),
                  ),
                  const SizedBox(height: 75),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}