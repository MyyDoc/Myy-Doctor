class ReelItems {
  final String reelId;
  final String ownerId;
  final String videoUrl;
  final String caption;
  final int createdAt;
  final int likeCount;
  final int commentCount;

  ReelItems({
    required this.reelId,
    required this.ownerId,
    required this.videoUrl,
    required this.caption,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
  });

  factory ReelItems.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];

    return ReelItems(
      reelId: map['reelId']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      videoUrl: map['videoUrl']?.toString() ?? '',
      caption: map['caption']?.toString() ?? '',
      createdAt: createdAtRaw is int ? createdAtRaw : 0,
      likeCount: map['likeCount'] is int ? map['likeCount'] : 0,
      commentCount: map['commentCount'] is int ? map['commentCount'] : 0,
    );
  }
}
