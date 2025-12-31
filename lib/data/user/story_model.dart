
// ==================== STORY MODEL ====================
class StoryModel {
  final String storyId;
  final String userId;
  final String mediaUrl;
  final String mediaType;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewers;
  final bool isArchived;

  StoryModel({
    required this.storyId,
    required this.userId,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.viewers = const [],
    this.isArchived = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'userId': userId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewers': viewers,
      'isArchived': isArchived,
    };
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['storyId'] ?? '',
      userId: json['userId'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'image',
      caption: json['caption'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : DateTime.now().add(Duration(hours: 24)),
      viewers: List<String>.from(json['viewers'] ?? []),
      isArchived: json['isArchived'] ?? false,
    );
  }
}
