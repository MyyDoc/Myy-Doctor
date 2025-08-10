import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/setting_options/widgets/setting_toggle_menu_tile_widget.dart';
import 'package:myydoctor/presentation/screens/setting_options/widgets/setting_subheading_text_widget.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWhite,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.black,
        title: Text(
          'Notifications',
          style: TextStyle(color: AppColors.caramel,fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            SettingSubHeadingText(text: 'In-App Notifications'),
            SizedBox(height: 10,),
            SettingToggleMenuTileWidget(text: 'In App Alert Sound'),
            SettingToggleMenuTileWidget(text: 'In-App Vibrate'),
            SizedBox(height: 10,),
            SettingSubHeadingText(text: 'Push Notifications'),
            SizedBox(height: 10,),
            SettingToggleMenuTileWidget(text: 'New Visitors'),
            SettingToggleMenuTileWidget(text: 'New Likes'),
            SettingToggleMenuTileWidget(text: 'New Matches'),
            SettingToggleMenuTileWidget(text: 'New Messages'),
            SettingToggleMenuTileWidget(text: 'New Comments'),
            SizedBox(height: 10,),
            SettingSubHeadingText(text: 'Mail Notifications'),
            SizedBox(height: 10,),
            SettingToggleMenuTileWidget(text: 'Unread Messages'),
            SettingToggleMenuTileWidget(text: 'Promotions'),
        
          ],
        ),
      ),
    );
  }
}

