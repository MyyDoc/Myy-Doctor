class ReelItems {
  final String reelId;
  final String ownerId;
  final String ownerName;
  final String ownerProfilePicUrl;
  final String videoUrl;
  final String caption;
  final int createdAt;
  final int likeCount;
  final int commentCount;

  ReelItems({
    required this.reelId,
    required this.ownerId,
    required this.ownerName,
    required this.ownerProfilePicUrl,
    required this.videoUrl,
    required this.caption,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
  });

  factory ReelItems.fromMap(Map<String, dynamic> map) {
    return ReelItems(
      reelId: map['reelId']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      ownerProfilePicUrl: map['ownerProfilePicUrl']?.toString() ?? '',
      videoUrl: map['videoUrl']?.toString() ?? '',
      caption: map['caption']?.toString() ?? '',
      createdAt: map['createdAt'] is int ? map['createdAt'] : 0,
      likeCount: map['likeCount'] is int ? map['likeCount'] : 0,
      commentCount: map['commentCount'] is int ? map['commentCount'] : 0,
    );
  }
}
