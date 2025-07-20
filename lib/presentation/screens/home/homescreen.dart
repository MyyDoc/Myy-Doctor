import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/home/homescreen_body.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/screens/reels/reels_contents.dart';
import 'package:myydoctor/presentation/screens/search/search_screen.dart';
import 'package:myydoctor/presentation/widgets/common_widgets.dart';
import 'package:myydoctor/services/location/location.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;
  String? currentCity;

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      String? city = await LocationService.getCurrentCity();
      setState(() {
        currentCity = city ?? "Kochi";
      });
    } catch (_) {
      setState(() {
        currentCity = "Kochi";
      });
    }
  }

  late final List<Widget> _screens = [
    const HomescreenBody(),
    SearchScreen(currentLoc: currentCity ?? "Kochi"),
    const ReelsContents(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageStorage(
            bucket: _bucket,
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            left: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: BottomNavBar(
                currentIndex: _currentIndex,
                onItemTapped: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
