import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myydoctor/domain/firebase_service.dart';
import 'package:myydoctor/firebase_options.dart';
import 'package:myydoctor/presentation/screens/auth/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/presentation/screens/profile/get_user/bloc/get_user_cubit/get_user_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile/bloc/profile_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_by_id/bloc/fetch_user_details_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_age/save_age_bloc.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_pic/save_profile_pic_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/profile_details_creation/bloc/save_profile_preference/save_profile_preference_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/save_post_cubit/save_post_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_pic_cubit/upload_pic_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/reel_post_uploding/bloc/upload_reel_cubit/upload_reel_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/story_view/bloc/fetch_story_cubit/fetch_my_stories_cubit.dart';
import 'package:myydoctor/presentation/screens/profile/story_view/bloc/upload_story_cubit/upload_story_cubit.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/reel_comment_cubit/reel_comment_cubit.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/reel_feed_cubit/reel_feed_cubit.dart';
import 'package:myydoctor/presentation/screens/search/cubit/search_near_doctor_cubit.dart';

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
        BlocProvider(create: (_) => ReelFeedCubit()),
        BlocProvider(create: (_) => ReelCommentCubit()),
        BlocProvider(create: (_) => UploadStoryCubit()),
        BlocProvider(create: (_) => FetchMyStoriesCubit()),
        BlocProvider(create: (_) => SavePostCubit(),),
        BlocProvider(create: (_) => FetchUserCubit(),),
        BlocProvider(create: (_) => ProfileCubit(FirebaseService()),),
        BlocProvider(create: (_) => FetchUserDetailsCubit(),),
        BlocProvider(create: (_) => SearchNearDoctorCubit(),),
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
