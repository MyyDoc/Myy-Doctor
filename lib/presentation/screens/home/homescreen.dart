import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/search/search_screen.dart';
import 'package:myydoctor/presentation/widgets/home/feed_container_item.dart';
import 'package:myydoctor/presentation/widgets/home/story_circle.dart';
import 'package:myydoctor/services/location/location.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

   @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  String? currentCity;

    Future<void> _getCurrentLocation() async {

    try {
      String? city = await LocationService.getCurrentCity();
      setState(() {
        currentCity = city;
      });
      print(city);
      print("cityyyyy");
    } catch (e) {
      
    }
  }

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
          Positioned(
            left: 15,
            right: 15,
            bottom: 15,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.home_rounded, color: Colors.white, size: 32),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen(currentLoc: currentCity ?? "Kochi",),)),
                    child: Icon(Icons.search, color: Colors.white, size: 32)),
                  Icon(Icons.add_box_outlined, color: Colors.white, size: 32),
                  Icon(
                    Icons.play_circle_outline_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
