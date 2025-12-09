
// ==================== REEL MODEL ====================
class ReelModel {
  final String reelId;
  final String userId;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isTrending;
  final List<String> hashtags;
  final String? audioUrl;

  ReelModel({
    required this.reelId,
    required this.userId,
    required this.videoUrl,
    this.thumbnailUrl,
    this.caption,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.isTrending = false,
    this.hashtags = const [],
    this.audioUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'reelId': reelId,
      'userId': userId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'isTrending': isTrending,
      'hashtags': hashtags,
      'audioUrl': audioUrl,
    };
  }

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      reelId: json['reelId'] ?? '',
      userId: json['userId'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      caption: json['caption'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
      isTrending: json['isTrending'] ?? false,
      hashtags: List<String>.from(json['hashtags'] ?? []),
      audioUrl: json['audioUrl'],
    );
  }
}
