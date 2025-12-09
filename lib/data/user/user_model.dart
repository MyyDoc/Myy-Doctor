import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== USER MODEL ====================
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profilePicture;
  final String? bio;
  final String? gender;
  final DateTime? dob;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final bool isVerified;
  final bool emailVerified;
  final bool phoneVerified;
  final List<String> savedPosts;
  final List<String> searchHistory;
  final String languagePreference;
  final List<String> deviceTokens;
  final String? location;
  final List<String> badges;
  final String subscriptionStatus;
  final double walletBalance;
  final bool notificationsEnabled;
  final List<String> followersList;
  final List<String> followingList;
  final List<String> subscribers;
  final List<String> chatUsers;
  final DateTime? lastSeen;
  final List<String> features;

  // Privacy settings
  final String privacy;
  final String themePreference;
  final List<String> blockedUsers;
  final List<String> mutedUsers;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profilePicture,
    this.bio,
    this.gender,
    this.dob,
    this.lastLogin,
    required this.createdAt,
    this.isVerified = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.savedPosts = const [],
    this.searchHistory = const [],
    this.languagePreference = 'en',
    this.deviceTokens = const [],
    this.location,
    this.badges = const [],
    this.subscriptionStatus = 'free',
    this.walletBalance = 0.0,
    this.notificationsEnabled = true,
    this.followersList = const [],
    this.followingList = const [],
    this.subscribers = const [],
    this.chatUsers = const [],
    this.lastSeen,
    this.features = const [],
    this.privacy = 'public',
    this.themePreference = 'light',
    this.blockedUsers = const [],
    this.mutedUsers = const [],
  });

  // Computed properties
  int get followersCount => followersList.length;
  int get followingCount => followingList.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'bio': bio,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'savedPosts': savedPosts,
      'searchHistory': searchHistory,
      'languagePreference': languagePreference,
      'deviceTokens': deviceTokens,
      'location': location,
      'badges': badges,
      'subscriptionStatus': subscriptionStatus,
      'walletBalance': walletBalance,
      'notificationsEnabled': notificationsEnabled,
      'followersList': followersList,
      'followingList': followingList,
      'subscribers': subscribers,
      'chatUsers': chatUsers,
      'lastSeen': lastSeen?.toIso8601String(),
      'features': features,
      'privacy': privacy,
      'themePreference': themePreference,
      'blockedUsers': blockedUsers,
      'mutedUsers': mutedUsers,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'] ?? '',
      profilePicture: json['profilePicture'],
      bio: json['bio'],
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      savedPosts: List<String>.from(json['savedPosts'] ?? []),
      searchHistory: List<String>.from(json['searchHistory'] ?? []),
      languagePreference: json['languagePreference'] ?? 'en',
      deviceTokens: List<String>.from(json['deviceTokens'] ?? []),
      location: json['location'],
      badges: List<String>.from(json['badges'] ?? []),
      subscriptionStatus: json['subscriptionStatus'] ?? 'free',
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      followersList: List<String>.from(json['followersList'] ?? []),
      followingList: List<String>.from(json['followingList'] ?? []),
      subscribers: List<String>.from(json['subscribers'] ?? []),
      chatUsers: List<String>.from(json['chatUsers'] ?? []),
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      features: List<String>.from(json['features'] ?? []),
      privacy: json['privacy'] ?? 'public',
      themePreference: json['themePreference'] ?? 'light',
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      mutedUsers: List<String>.from(json['mutedUsers'] ?? []),
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? profilePicture,
    String? bio,
    String? gender,
    DateTime? dob,
    DateTime? lastLogin,
    DateTime? createdAt,
    bool? isVerified,
    bool? emailVerified,
    bool? phoneVerified,
    List<String>? savedPosts,
    List<String>? searchHistory,
    String? languagePreference,
    List<String>? deviceTokens,
    String? location,
    List<String>? badges,
    String? subscriptionStatus,
    double? walletBalance,
    bool? notificationsEnabled,
    List<String>? followersList,
    List<String>? followingList,
    List<String>? subscribers,
    List<String>? chatUsers,
    DateTime? lastSeen,
    List<String>? features,
    String? privacy,
    String? themePreference,
    List<String>? blockedUsers,
    List<String>? mutedUsers,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      savedPosts: savedPosts ?? this.savedPosts,
      searchHistory: searchHistory ?? this.searchHistory,
      languagePreference: languagePreference ?? this.languagePreference,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      location: location ?? this.location,
      badges: badges ?? this.badges,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      walletBalance: walletBalance ?? this.walletBalance,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      followersList: followersList ?? this.followersList,
      followingList: followingList ?? this.followingList,
      subscribers: subscribers ?? this.subscribers,
      chatUsers: chatUsers ?? this.chatUsers,
      lastSeen: lastSeen ?? this.lastSeen,
      features: features ?? this.features,
      privacy: privacy ?? this.privacy,
      themePreference: themePreference ?? this.themePreference,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      mutedUsers: mutedUsers ?? this.mutedUsers,
    );
  }
}

// ==================== PAYMENT MODEL ====================
class PaymentModel {
  final String paymentId;
  final String userId;
  final double amount;
  final String transactionType;
  final String transactionStatus;
  final DateTime createdAt;
  final String? subscriptionStatus;
  final String? description;

  PaymentModel({
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.transactionType,
    this.transactionStatus = 'pending',
    required this.createdAt,
    this.subscriptionStatus,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'amount': amount,
      'transactionType': transactionType,
      'transactionStatus': transactionStatus,
      'createdAt': createdAt.toIso8601String(),
      'subscriptionStatus': subscriptionStatus,
      'description': description,
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['paymentId'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      transactionType: json['transactionType'] ?? 'credit',
      transactionStatus: json['transactionStatus'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      subscriptionStatus: json['subscriptionStatus'],
      description: json['description'],
    );
  }
}
