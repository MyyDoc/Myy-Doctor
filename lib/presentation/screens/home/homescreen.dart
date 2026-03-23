import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:myydoctor/presentation/screens/notifications/notification_screen.dart';
import 'package:myydoctor/presentation/screens/profile/profile_screen.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/reel_feed_cubit/reel_feed_cubit.dart';
import 'package:myydoctor/presentation/screens/reels/reels_contents.dart';
import 'package:myydoctor/presentation/screens/search/search_screen.dart';
import 'package:myydoctor/presentation/widgets/common_widgets.dart';
import 'package:myydoctor/services/location/location.dart';

import '../profile/get_user/bloc/get_user_cubit/get_user_cubit.dart';
import '../profile/profile/bloc/profile_cubit.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;
  String? currentCity;

  final Map<int, Widget> _createdScreens = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    context.read<FetchUserCubit>().fetchUser();
    context.read<ProfileCubit>().listenToUserProfile();
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

  Widget _getScreen(int index, {bool isVisible = false}) {
  if (index == 2) {
    return BlocProvider(
      create: (_) => ReelFeedCubit()..fetchInitial(),
      child: ReelsScreen(isVisible: isVisible),
    );
  }

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
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _getScreen(0),
                  _getScreen(1),
                  _getScreen(2, isVisible: _currentIndex == 2),
                  _getScreen(3),
                ],
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
