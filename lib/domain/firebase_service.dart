import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/user/comment_model.dart';
import '../data/user/message_model.dart';
import '../data/user/notification_model.dart';
import '../data/user/posts_model.dart';
import '../data/user/reels_model.dart';
import '../data/user/saved_posts_model.dart';
import '../data/user/story_model.dart';
import '../data/user/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get postsCollection => _firestore.collection('posts');
  CollectionReference get reelsCollection => _firestore.collection('reels');
  CollectionReference get storiesCollection => _firestore.collection('stories');
  CollectionReference get messagesCollection => _firestore.collection('messages');
  CollectionReference get notificationsCollection => _firestore.collection('notifications');
  CollectionReference get commentsCollection => _firestore.collection('comments');
  CollectionReference get paymentsCollection => _firestore.collection('payments');
  CollectionReference get savedPostsCollection => _firestore.collection('savedPosts');

  /// Initialize empty user data on signup
  Future<void> createUserDocument({
    required String userId,
    required String email,
    required String username,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final userData = UserModel(
        id: userId,
        username: username,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        // All other fields will use default values from constructor
      );

      await usersCollection.doc(userId).set(userData.toJson());
      print('✅ User document created successfully');
    } catch (e) {
      print('❌ Error creating user document: $e');
      rethrow;
    }
  }

  /// Update user fields
  Future<void> updateUserField({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await usersCollection.doc(userId).update(updates);
      print('✅ User fields updated successfully');
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }

  /// Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      rethrow;
    }
  }

  /// Create a post
  Future<void> createPost(PostModel post) async {
    try {
      await postsCollection.doc(post.postId).set(post.toJson());

      // Update user's post count
      await updateUserField(
        userId: post.userId,
        updates: {
          'postsCount': FieldValue.increment(1),
        },
      );

      print('✅ Post created successfully');
    } catch (e) {
      print('❌ Error creating post: $e');
      rethrow;
    }
  }

  /// Create a story
  Future<void> createStory(StoryModel story) async {
    try {
      await storiesCollection.doc(story.storyId).set(story.toJson());

      // Update user's story count
      await updateUserField(
        userId: story.userId,
        updates: {
          'storiesCount': FieldValue.increment(1),
        },
      );

      print('✅ Story created successfully');
    } catch (e) {
      print('❌ Error creating story: $e');
      rethrow;
    }
  }

  // /// Create a reel
  // Future<void> createReel(ReelModel reel) async {
  //   try {
  //     await reelsCollection.doc(reel.reelId).set(reel.toJson());
  //     print('✅ Reel created successfully');
  //   } catch (e) {
  //     print('❌ Error creating reel: $e');
  //     rethrow;
  //   }
  // }

  /// Send a message
  Future<void> sendMessage(MessageModel message) async {
    try {
      await messagesCollection.doc(message.messageId).set(message.toJson());

      // Add both users to each other's chat users list
      await updateUserField(
        userId: message.senderId,
        updates: {
          'chatUsers': FieldValue.arrayUnion([message.receiverId]),
        },
      );

      await updateUserField(
        userId: message.receiverId,
        updates: {
          'chatUsers': FieldValue.arrayUnion([message.senderId]),
        },
      );

      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Create notification
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await notificationsCollection.doc(notification.notificationId).set(notification.toJson());
      print('✅ Notification created successfully');
    } catch (e) {
      print('❌ Error creating notification: $e');
      rethrow;
    }
  }

  /// Add comment
  Future<void> addComment(CommentModel comment) async {
    try {
      await commentsCollection.doc(comment.commentId).set(comment.toJson());

      // Update post's comment count
      await postsCollection.doc(comment.postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      print('✅ Comment added successfully');
    } catch (e) {
      print('❌ Error adding comment: $e');
      rethrow;
    }
  }

  /// Save post
  Future<void> savePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final savedId = '${userId}_$postId';
      final savedPost = SavedPostModel(
        savedId: savedId,
        userId: userId,
        postId: postId,
        savedAt: DateTime.now(),
      );

      await savedPostsCollection.doc(savedId).set(savedPost.toJson());

      // Add to user's saved posts
      await updateUserField(
        userId: userId,
        updates: {
          'savedPosts': FieldValue.arrayUnion([postId]),
        },
      );

      print('✅ Post saved successfully');
    } catch (e) {
      print('❌ Error saving post: $e');
      rethrow;
    }
  }

  /// Unsave post
  Future<void> unsavePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final savedId = '${userId}_$postId';
      await savedPostsCollection.doc(savedId).delete();

      // Remove from user's saved posts
      await updateUserField(
        userId: userId,
        updates: {
          'savedPosts': FieldValue.arrayRemove([postId]),
        },
      );

      print('✅ Post unsaved successfully');
    } catch (e) {
      print('❌ Error unsaving post: $e');
      rethrow;
    }
  }

  /// Follow user
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Add to current user's following list
      await updateUserField(
        userId: currentUserId,
        updates: {
          'followingList': FieldValue.arrayUnion([targetUserId]),
        },
      );

      // Add to target user's followers list
      await updateUserField(
        userId: targetUserId,
        updates: {
          'followersList': FieldValue.arrayUnion([currentUserId]),
        },
      );

      print('✅ User followed successfully');
    } catch (e) {
      print('❌ Error following user: $e');
      rethrow;
    }
  }

  /// Unfollow user
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Remove from current user's following list
      await updateUserField(
        userId: currentUserId,
        updates: {
          'followingList': FieldValue.arrayRemove([targetUserId]),
        },
      );

      // Remove from target user's followers list
      await updateUserField(
        userId: targetUserId,
        updates: {
          'followersList': FieldValue.arrayRemove([currentUserId]),
        },
      );

      print('✅ User unfollowed successfully');
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      rethrow;
    }
  }

  /// Like post
  Future<void> likePost(String postId) async {
    try {
      await postsCollection.doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
      print('✅ Post liked successfully');
    } catch (e) {
      print('❌ Error liking post: $e');
      rethrow;
    }
  }

  /// Unlike post
  Future<void> unlikePost(String postId) async {
    try {
      await postsCollection.doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
      print('✅ Post unliked successfully');
    } catch (e) {
      print('❌ Error unliking post: $e');
      rethrow;
    }
  }

  /// Update last seen
  Future<void> updateLastSeen(String userId) async {
    try {
      await updateUserField(
        userId: userId,
        updates: {
          'lastSeen': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('❌ Error updating last seen: $e');
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUserData(String userId) {
    return usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Stream user's posts
  Stream<List<PostModel>> streamUserPosts(String userId) {
    return postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Stream notifications
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Stream messages
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return messagesCollection
        .where('chatId', isEqualTo: chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}

// Usage example for signup:
/*
class AuthService {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      // Create Firebase Auth user
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Create Firestore document with empty/default values
        await _firebaseService.createUserDocument(
          userId: user.uid,
          email: email,
          username: username,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );

        return user;
      }
      return null;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }
}
*/