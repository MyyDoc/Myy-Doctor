import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/notifications/notification_screen.dart';
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
  
  final Map<int, Widget> _createdScreens = {};
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

  Widget _getScreen(int index) {
    // Return cached screen if already created
    if (_createdScreens.containsKey(index)) {
      return _createdScreens[index]!;
    }

    Widget screen;
    switch (index) {
      case 0:
        screen = const ProfileScreen();
        break;
      case 1:
        screen = SearchScreen(currentLoc: currentCity ?? "Kochi");
        break;
      case 2:
        // Only create ReelsView when user navigates to this tab
        screen = ReelsView(
          reels: [
            ReelItem(
              id: '1',
              username: 'user1',
              profilePicture: 'https://picsum.photos/100/100?random=1',
              videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              description: 'Check out this amazing video! #viral #trending',
              musicTitle: 'Original Audio - user1',
              likes: 1250,
              comments: 89,
              shares: 45,
            ),
            ReelItem(
              id: '2',
              username: 'user2',
              profilePicture: 'https://picsum.photos/100/100?random=2',
              videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
              description: 'Another cool reel for you to enjoy!',
              musicTitle: 'Trending Song - Artist',
              likes: 890,
              comments: 67,
              shares: 23,
            ),
            ReelItem(
              id: '3',
              username: 'user3',
              profilePicture: 'https://picsum.photos/100/100?random=3',
              videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
              description: 'Amazing content here! Don\'t forget to like and follow 🔥',
              musicTitle: 'Popular Sound - Viral Track',
              likes: 2340,
              comments: 156,
              shares: 78,
            ),
          ],
        );
        break;
      case 3:
        screen = NotificationsScreen();
        break;
      default:
        screen = const ProfileScreen();
    }

    // Cache the screen
    _createdScreens[index] = screen;
    return screen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageStorage(
              bucket: _bucket,
              child: _getScreen(_currentIndex),
            ),
          ),
          BottomNavBar(
            currentIndex: _currentIndex,
            onItemTapped: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}