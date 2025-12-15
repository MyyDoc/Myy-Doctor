import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myydoctor/firebase_options.dart';
import 'package:myydoctor/presentation/screens/auth/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_age/save_age_bloc.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_pic/save_profile_pic_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_pic_cubit/upload_pic_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_reel_cubit/upload_reel_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SaveProfilePreferenceCubit()),
        BlocProvider(create: (_) => SaveAgeBloc()),
        BlocProvider(create: (_) => SaveProfilePicCubit()),
        BlocProvider(create: (_) => UploadPicCubit()),
        BlocProvider(create: (_) => UploadReelCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // showPerformanceOverlay: true,
      builder: (context, child) {
        return SafeArea(top: false, child: child ?? const SizedBox());
      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demoooooo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.cormorantGaramondTextTheme(),
      ),
      home: SplashScreen(),
    );
  }
}
