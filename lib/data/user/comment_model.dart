
// ==================== COMMENT MODEL ====================
class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final List<String> replies;
  final String? parentCommentId;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.replies = const [],
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'replies': replies,
      'parentCommentId': parentCommentId,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
      replies: List<String>.from(json['replies'] ?? []),
      parentCommentId: json['parentCommentId'],
    );
  }
}
