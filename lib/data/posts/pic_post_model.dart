class PicPostModel {
  final String postId;
  final String ownerId;
  final String caption;
  final String imageUrl;
  final int likeCount;
  final int commentCount;
  final String? name;              // User's display name
  final String? profileImageUrl;   // User's profile picture
  final int createdAt;             // Timestamp in milliseconds
  final bool isSaved;              // Whether current user saved this post
  final bool isOwnerDoctor;        // Whether the post owner is a doctor

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
    required this.isOwnerDoctor,
  });

  /// Factory constructor used when creating model from Firestore document
  factory PicPostModel.fromMap(
      Map<String, dynamic> map,
      String postId,
      String ownerId, {
        bool isSaved = false,           // Can be passed separately
        bool? isOwnerDoctor,            // Can be passed separately (recommended)
      }) {
    return PicPostModel(
      postId: postId,
      ownerId: ownerId,
      caption: map['caption'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      likeCount: (map['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (map['commentCount'] as num?)?.toInt() ?? 0,
      name: map['username'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
      isSaved: isSaved,
      isOwnerDoctor: isOwnerDoctor ?? false, // fallback if not provided
    );
  }

  /// Convenient factory when you already have the doctor status
  factory PicPostModel.fromPostAndUser({
    required Map<String, dynamic> postMap,
    required String postId,
    required String ownerId,
    required bool isOwnerDoctor,
    bool isSaved = false,
  }) {
    return PicPostModel.fromMap(
      postMap,
      postId,
      ownerId,
      isSaved: isSaved,
      isOwnerDoctor: isOwnerDoctor,
    );
  }

  /// Create a copy with updated fields (very useful for state management)
  PicPostModel copyWith({
    String? caption,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
    String? name,
    String? profileImageUrl,
    int? createdAt,
    bool? isSaved,
    bool? isOwnerDoctor,
  }) {
    return PicPostModel(
      postId: postId,
      ownerId: ownerId,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
      isOwnerDoctor: isOwnerDoctor ?? this.isOwnerDoctor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PicPostModel &&
              runtimeType == other.runtimeType &&
              postId == other.postId &&
              ownerId == other.ownerId &&
              isSaved == other.isSaved &&
              isOwnerDoctor == other.isOwnerDoctor;

  @override
  int get hashCode => Object.hash(
    postId,
    ownerId,
    isSaved,
    isOwnerDoctor,
  );

  /// Optional: for debugging
  @override
  String toString() {
    return 'PicPostModel(postId: $postId, owner: $ownerId, doctor: $isOwnerDoctor, '
        'likes: $likeCount, saved: $isSaved, name: $name)';
  }
}