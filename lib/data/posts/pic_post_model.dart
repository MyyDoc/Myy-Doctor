class PicPostModel {
  final String postId;
  final String ownerId;
  final String caption;
  final String imageUrl;
  final int likeCount;
  final int commentCount;
  String? name;
  String? profileImageUrl;
  final int createdAt; // timestamp (ms)

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
  });

factory PicPostModel.fromMap(Map<dynamic, dynamic> map, {String? id}) {
  return PicPostModel(
    postId: id ?? map['postId'] ?? '',
    ownerId: map['ownerId'] ?? '',
    caption: map['caption'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    likeCount: map['likeCount'] ?? 0,
    commentCount: map['commentCount'] ?? 0,
    createdAt: map['createdAt'] ?? 0,
  );
}

}
