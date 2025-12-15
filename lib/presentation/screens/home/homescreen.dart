import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:myydoctor/presentation/screens/notifications/notification_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/cubit/reel_feed_cubit.dart';
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
    if (_createdScreens.containsKey(index)) {
      return _createdScreens[index]!;
    }

    late Widget screen;

    switch (index) {
      case 0:
        screen = const ProfileScreen();
        break;

      case 1:
        screen = SearchScreen(currentLoc: currentCity ?? "Kochi");
        break;

      case 2:
        /// ✅ FIREBASE REELS (FIX)
        screen = BlocProvider(
          create: (_) => ReelFeedCubit()..fetchInitial(),
          child: const ReelsScreen(),
        );
        break;

      case 3:
        screen = NotificationsScreen();
        break;

      default:
        screen = const ProfileScreen();
    }

    _createdScreens[index] = screen;
    return screen;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
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
      ),
    );
  }
}
