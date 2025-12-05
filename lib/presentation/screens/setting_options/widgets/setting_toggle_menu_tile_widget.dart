import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

class SettingToggleMenuTileWidget extends StatefulWidget {
  final String text;
  final bool icon;
  final IconData? iconData;
  final bool showToggle;
  const SettingToggleMenuTileWidget({
    super.key,
    required this.text,
    this.icon = false,
    this.iconData,
    this.showToggle = true,
  });

  @override
  State<SettingToggleMenuTileWidget> createState() =>
      _NotificationToggleMenuTileWidgetState();
}

class _NotificationToggleMenuTileWidgetState
    extends State<SettingToggleMenuTileWidget> {
  bool isEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: icon + text
          Expanded(
            child: Row(
              children: [
                if (widget.icon) ...[
                  Icon(widget.iconData),
                  SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.text,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Right side: switch
          widget.showToggle
              ? Switch(
                activeTrackColor: AppColors.green,
                inactiveTrackColor: AppColors.white,
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    isEnabled = value;
                  });
                },
              )
              : SizedBox(
                width: 59, // approximate width of a standard Switch
                height: 30,
              ),
        ],
      ),
    );
  }
}
