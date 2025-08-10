import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/setting_options/widgets/setting_subheading_text_widget.dart';
import 'package:myydoctor/presentation/screens/setting_options/widgets/setting_toggle_menu_tile_widget.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWhite,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.black,
        title: Text(
          'Privacy',
          style: TextStyle(
            color: AppColors.caramel,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingToggleMenuTileWidget(
              text: 'Hide Profile on Match & SEarch',
              icon: true,
              iconData: Icons.hide_image,
            ),
            SizedBox(height: 10),
            SettingSubHeadingText(
              text: 'Only users you liked can see your profile on Match & Search',
            ),
            SizedBox(height: 10),
            SettingToggleMenuTileWidget(text: 'Anonymous Visitor',icon: true, iconData: Icons.visibility,),
            SizedBox(height: 10,),
            SettingSubHeadingText(text: 'You wont appear on others visitor list'),
            SizedBox(height: 10,),
            SettingToggleMenuTileWidget(text: 'Do Not Disturb',icon: true,iconData: Icons.do_not_disturb,),
            SizedBox(height: 10,),
            SettingSubHeadingText(text: 'Stop receiving new messages'),
            SizedBox(height: 10,),
            SettingToggleMenuTileWidget(text: 'Turn off Read Recipt',icon: true, iconData: Icons.check,),
            SizedBox(height: 10,),
            SettingSubHeadingText(text: 'If you turn this off all of your matches wont be able to receive the read recipt when chatting with you.'),
            SizedBox(height: 10,),
            SettingToggleMenuTileWidget(text: 'Hide my Location'),
            SizedBox(height: 10,),
            SettingSubHeadingText(text: 'Hide my location from others'),
            SizedBox(height: 10,),
            SettingToggleMenuTileWidget(text: 'Sync profile photos to Moments'),
            SettingToggleMenuTileWidget(text: 'Profile Costume'),
            SettingToggleMenuTileWidget(text: 'Privacy', showToggle: false),
            SettingToggleMenuTileWidget(text: 'Terms', showToggle: false),
            SizedBox(height: 40,),
          ],
        ),
      ),
    );
  }
}
