import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myydoctor/presentation/screens/chat/chat_list.dart';
import 'package:myydoctor/presentation/screens/chat/chat_screen.dart';
import 'package:video_player/video_player.dart';

class ReelsView extends StatefulWidget {
  final List<ReelItem> reels;

  const ReelsView({Key? key, required this.reels}) : super(key: key);

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentIndex = 0;
  List<VideoPlayerController?> _controllers = [];
  
  // Only initialize controllers for current and adjacent videos to save memory
  final Set<int> _initializedControllers = {};
  final int _preloadRange = 1; // How many videos to preload before/after current

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // Pause all videos when app goes to background
      _pauseAllVideos();
    } else if (state == AppLifecycleState.resumed) {
      // Resume current video when app comes back to foreground
      if (mounted && _controllers[_currentIndex]?.value.isInitialized == true) {
        _controllers[_currentIndex]?.play();
      }
    }
  }

  void _initializeControllers() {
    // Initialize empty list first
    _controllers = List.generate(widget.reels.length, (index) => null);
    
    // Only initialize the first video and its neighbors
    _initializeControllersInRange(_currentIndex);
  }

  void _initializeControllersInRange(int centerIndex) {
    final start = (centerIndex - _preloadRange).clamp(0, widget.reels.length - 1);
    final end = (centerIndex + _preloadRange).clamp(0, widget.reels.length - 1);
    
    for (int i = start; i <= end; i++) {
      if (!_initializedControllers.contains(i)) {
        _initializeController(i);
      }
    }
    
    // Dispose controllers that are too far from current index
    _disposeDistantControllers(centerIndex);
  }

  void _initializeController(int index) {
    if (index >= 0 && index < widget.reels.length) {
      _controllers[index] = VideoPlayerController.network(
        widget.reels[index].videoUrl,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false, // Don't mix with other audio
          allowBackgroundPlayback: false, // Prevent background playback
        ),
      )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          if (index == _currentIndex) {
            _controllers[index]?.play();
          }
        }
      }).catchError((error) {
        print('Error initializing video $index: $error');
      });
      
      _initializedControllers.add(index);
    }
  }

  void _disposeDistantControllers(int centerIndex) {
    final keepStart = (centerIndex - _preloadRange - 1).clamp(0, widget.reels.length - 1);
    final keepEnd = (centerIndex + _preloadRange + 1).clamp(0, widget.reels.length - 1);
    
    for (int i = 0; i < _controllers.length; i++) {
      if ((i < keepStart || i > keepEnd) && _initializedControllers.contains(i)) {
        _controllers[i]?.dispose();
        _controllers[i] = null;
        _initializedControllers.remove(i);
      }
    }
  }

  void _pauseAllVideos() {
    for (var controller in _controllers) {
      if (controller?.value.isInitialized == true && controller!.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void _onPageChanged(int index) {
    // Pause previous video
    if (_controllers[_currentIndex]?.value.isInitialized == true) {
      _controllers[_currentIndex]?.pause();
    }

    // Update current index
    _currentIndex = index;

    // Initialize controllers in new range
    _initializeControllersInRange(index);

    // Play current video if ready
    if (_controllers[index]?.value.isInitialized == true) {
      _controllers[index]?.play();
    }

    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    
    // Properly dispose all controllers
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i]?.dispose();
    }
    _controllers.clear();
    _initializedControllers.clear();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: widget.reels.length,
        itemBuilder: (context, index) {
          return ReelWidget(
            reel: widget.reels[index],
            controller: _controllers[index],
            isCurrentReel: index == _currentIndex,
          );
        },
      ),
    );
  }
}

class ReelWidget extends StatefulWidget {
  final ReelItem reel;
  final VideoPlayerController? controller;
  final bool isCurrentReel;

  const ReelWidget({
    Key? key,
    required this.reel,
    this.controller,
    required this.isCurrentReel,
  }) : super(key: key);

  @override
  State<ReelWidget> createState() => _ReelWidgetState();
}

class _ReelWidgetState extends State<ReelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLiked = false;
  bool _showPlayPause = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _isLiked = widget.reel.isLiked;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (widget.controller?.value.isPlaying == true) {
      widget.controller?.pause();
    } else {
      widget.controller?.play();
    }

    setState(() {
      _showPlayPause = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showPlayPause = false;
        });
      }
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        GestureDetector(
          onTap: _togglePlayPause,
          child: widget.controller?.value.isInitialized == true
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: widget.controller!.value.size.width,
                      height: widget.controller!.value.size.height,
                      child: VideoPlayer(widget.controller!),
                    ),
                  ),
                )
              : widget.controller?.value.hasError == true
                  ? Container(
                      color: Colors.grey[900],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white54,
                            size: 50,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Video unavailable',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      color: Colors.grey[900],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading video...',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),

        // Play/Pause Indicator
        if (_showPlayPause)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                widget.controller?.value.isPlaying == true
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),

        // Like Animation
        Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.2).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.elasticOut,
              ),
            ),
            child: Icon(
              Icons.favorite,
              color: _isLiked ? Colors.red : Colors.transparent,
              size: 100,
            ),
          ),
        ),

        // Right Side Actions
        Positioned(
          right: 10,
          bottom: 80,
          child: Column(
            children: [
              _buildActionButton(
                child: FaIcon(
                  FontAwesomeIcons.stethoscope,
                  size: 24,
                  color: Color(0xFFD4AF37),
                  shadows: [
                    Shadow(
                      color: Colors.black
                    )
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(),));
                },
              ),

              const SizedBox(height: 20),

              _buildActionButton(
                child: const Icon(
                  Icons.message_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListScreen(),));
                },
              ),

              const SizedBox(height: 20),

              // More Options
              _buildActionButton(
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 30,
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListScreen(),));
                },
              ),
            ],
          ),
        ),

        // Bottom User Info
        Positioned(
          left: 10,
          right: 70,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(widget.reel.profilePicture),
                  ),
                  const SizedBox(width: 10,),
                  Text(
                    '@${widget.reel.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 215, 176, 85),
                                    Colors.grey.shade300,
                                    Color.fromARGB(255, 215, 176, 85),
                                  ],
                                  stops: [0.0, 0.5, 1.0],
                                ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("  Follow  ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                widget.reel.description,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Music Info
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.reel.musicTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Progress Indicator
        if (widget.controller?.value.isInitialized == true)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              widget.controller!,
              allowScrubbing: false,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required Widget child,
    required VoidCallback onTap,
    String? label,
  }) {
    return Column(
      children: [
        GestureDetector(onTap: onTap, child: child),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class ReelItem {
  final String id;
  final String username;
  final String profilePicture;
  final String videoUrl;
  final String description;
  final String musicTitle;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;

  ReelItem({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.videoUrl,
    required this.description,
    required this.musicTitle,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
  });
}