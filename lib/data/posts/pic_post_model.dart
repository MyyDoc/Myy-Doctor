class PicPostModel {
  final String postId;
  final String ownerId;
  final String caption;
  final String imageUrl;
  final int likeCount;
  final int commentCount;
  final String? name;              // User's display name
  final String? profileImageUrl;    // User's profile pic
  final int createdAt;             // Timestamp in milliseconds
  final bool isSaved;               // Whether current user saved this post

  PicPostModel({
    required this.postId,
    required this.ownerId,
    required this.caption,
    required this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    this.name,
    this.profileImageUrl,
    required this.createdAt,
    this.isSaved = false,
  });

  // Factory to create from Firebase map
  factory PicPostModel.fromMap(Map<dynamic, dynamic> map, String postId, String ownerId) {
    return PicPostModel(
      postId: postId,
      ownerId: ownerId,
      caption: map['caption'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      name: map['name'] as String?,                    // Can come from post data
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: map['createdAt'] ?? 0,
      isSaved: false, // Will be overridden later by repository
    );
  }

  // Essential: Allows updating isSaved without changing other fields
  PicPostModel copyWith({
    bool? isSaved,
    String? name,
    String? profileImageUrl,
    int? likeCount,
    int? commentCount,
  }) {
    return PicPostModel(
      postId: postId,
      ownerId: ownerId,
      caption: caption,
      imageUrl: imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PicPostModel &&
              runtimeType == other.runtimeType &&
              postId == other.postId &&
              ownerId == other.ownerId &&
              isSaved == other.isSaved;

  @override
  int get hashCode => Object.hash(postId, ownerId, isSaved);
}