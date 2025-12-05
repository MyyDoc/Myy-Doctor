import 'dart:ui';

import 'package:flutter/material.dart';

class NotificationItem {
  final String avatar;
  final String name;
  final String message;
  final String time;
  final String? buttonText;
  final Color? buttonColor;
  final bool hasNewBadge;
  final IconData? socialIcon;
  final Color? socialIconColor;

  NotificationItem({
    required this.avatar,
    required this.name,
    required this.message,
    required this.time,
    this.buttonText,
    this.buttonColor,
    this.hasNewBadge = false,
    this.socialIcon,
    this.socialIconColor,
  });
}