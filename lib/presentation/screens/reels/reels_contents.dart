import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/data/user/reels_model.dart';
import 'package:myydoctor/presentation/screens/reels/bloc/cubit/reel_feed_cubit.dart';
import 'package:myydoctor/presentation/widgets/app_snackbar.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<ReelFeedCubit, ReelFeedState>(
        listener: (context, state) {
          if(state is ReelFeedError){
            showAppSnackBar(context, state.error.toString());
          }
        },
        child: BlocBuilder<ReelFeedCubit, ReelFeedState>(
          builder: (context, state) {
            if (state is ReelFeedLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReelFeedLoaded) {
              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: state.reels.length,
                onPageChanged: (index) {
                  if (index >= state.reels.length - 2) {
                    context.read<ReelFeedCubit>().fetchMore();
                  }
                },
                itemBuilder: (_, index) {
                  return FirebaseReelWidget(reel: state.reels[index]);
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class FirebaseReelWidget extends StatefulWidget {
  final ReelItems reel;
  const FirebaseReelWidget({super.key, required this.reel});

  @override
  State<FirebaseReelWidget> createState() => _FirebaseReelWidgetState();
}

class _FirebaseReelWidgetState extends State<FirebaseReelWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.reel.videoUrl),
      )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _controller.value.isInitialized
              ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
              : const Center(child: CircularProgressIndicator()),

          Positioned(
            left: 16,
            bottom: 40,
            child: Text(
              widget.reel.caption,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
