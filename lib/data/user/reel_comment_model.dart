class ReelComment {
  final String commentId;
  final String reelId;
  final String userId;
  final String userName;
  final String userProfilePicUrl;
  final String text;
  final int createdAt;

  const ReelComment({
    required this.commentId,
    required this.reelId,
    required this.userId,
    required this.userName,
    required this.userProfilePicUrl,
    required this.text,
    required this.createdAt,
  });

  factory ReelComment.fromMap(Map<String, dynamic> map) {
    return ReelComment(
      commentId: map['commentId']?.toString() ?? '',
      reelId: map['reelId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userProfilePicUrl: map['userProfilePicUrl']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: map['createdAt'] is int ? map['createdAt'] : 0,
    );
  }
}
