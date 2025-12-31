
// ==================== SAVED POST MODEL ====================
class SavedPostModel {
  final String savedId;
  final String userId;
  final String postId;
  final DateTime savedAt;

  SavedPostModel({
    required this.savedId,
    required this.userId,
    required this.postId,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'savedId': savedId,
      'userId': userId,
      'postId': postId,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedPostModel.fromJson(Map<String, dynamic> json) {
    return SavedPostModel(
      savedId: json['savedId'] ?? '',
      userId: json['userId'] ?? '',
      postId: json['postId'] ?? '',
      savedAt: json['savedAt'] != null ? DateTime.parse(json['savedAt']) : DateTime.now(),
    );
  }
}