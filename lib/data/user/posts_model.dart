
// ==================== POST/FEED MODEL ====================
class PostModel {
  final String postId;
  final String userId;
  final List<String> mediaUrls;
  final String mediaType;
  final String? caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final String? location;
  final List<String> taggedUsers;
  final List<String> hashtags;

  PostModel({
    required this.postId,
    required this.userId,
    this.mediaUrls = const [],
    this.mediaType = 'image',
    this.caption,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.location,
    this.taggedUsers = const [],
    this.hashtags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'location': location,
      'taggedUsers': taggedUsers,
      'hashtags': hashtags,
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      mediaType: json['mediaType'] ?? 'image',
      caption: json['caption'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      location: json['location'],
      taggedUsers: List<String>.from(json['taggedUsers'] ?? []),
      hashtags: List<String>.from(json['hashtags'] ?? []),
    );
  }
}
