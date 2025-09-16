import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/widgets/colours.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showAppSnackBar(BuildContext context, String message){
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: AppColors.red , content: Text(message)),);
}