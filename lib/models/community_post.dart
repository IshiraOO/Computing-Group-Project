class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final DateTime timestamp;
  final String title;
  final String content;
  final List<String> tags;
  final List<String> imageUrls;
  final bool isEmergency;
  final bool isResolved;
  final List<CommunityResponse> responses;
  final int viewCount;
  final List<String> likedByUsers;
  final Map<String, dynamic> additionalInfo; // For any extra information

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl = '',
    required this.timestamp,
    required this.title,
    required this.content,
    this.tags = const [],
    this.imageUrls = const [],
    this.isEmergency = false,
    this.isResolved = false,
    this.responses = const [],
    this.viewCount = 0,
    this.likedByUsers = const [],
    this.additionalInfo = const {},
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
      isEmergency: json['isEmergency'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
      responses: json['responses'] != null
          ? (json['responses'] as List)
              .map((response) => CommunityResponse.fromJson(response))
              .toList()
          : [],
      viewCount: json['viewCount'] as int? ?? 0,
      likedByUsers: json['likedByUsers'] != null ? List<String>.from(json['likedByUsers']) : [],
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'content': content,
      'tags': tags,
      'imageUrls': imageUrls,
      'isEmergency': isEmergency,
      'isResolved': isResolved,
      'responses': responses.map((response) => response.toJson()).toList(),
      'viewCount': viewCount,
      'likedByUsers': likedByUsers,
      'additionalInfo': additionalInfo,
    };
  }

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    DateTime? timestamp,
    String? title,
    String? content,
    List<String>? tags,
    List<String>? imageUrls,
    bool? isEmergency,
    bool? isResolved,
    List<CommunityResponse>? responses,
    int? viewCount,
    List<String>? likedByUsers,
    Map<String, dynamic>? additionalInfo,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      isEmergency: isEmergency ?? this.isEmergency,
      isResolved: isResolved ?? this.isResolved,
      responses: responses ?? this.responses,
      viewCount: viewCount ?? this.viewCount,
      likedByUsers: likedByUsers ?? this.likedByUsers,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

class CommunityResponse {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final DateTime timestamp;
  final String content;
  final List<String> imageUrls;
  final bool isVerifiedResponder; // Indicates if the responder has medical training
  final List<String> likedByUsers;
  final List<CommunityResponse> replies; // For nested replies

  CommunityResponse({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl = '',
    required this.timestamp,
    required this.content,
    this.imageUrls = const [],
    this.isVerifiedResponder = false,
    this.likedByUsers = const [],
    this.replies = const [],
  });

  factory CommunityResponse.fromJson(Map<String, dynamic> json) {
    return CommunityResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      content: json['content'] as String,
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
      isVerifiedResponder: json['isVerifiedResponder'] as bool? ?? false,
      likedByUsers: json['likedByUsers'] != null ? List<String>.from(json['likedByUsers']) : [],
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((reply) => CommunityResponse.fromJson(reply))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'timestamp': timestamp.toIso8601String(),
      'content': content,
      'imageUrls': imageUrls,
      'isVerifiedResponder': isVerifiedResponder,
      'likedByUsers': likedByUsers,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }

  CommunityResponse copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    DateTime? timestamp,
    String? content,
    List<String>? imageUrls,
    bool? isVerifiedResponder,
    List<String>? likedByUsers,
    List<CommunityResponse>? replies,
  }) {
    return CommunityResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerifiedResponder: isVerifiedResponder ?? this.isVerifiedResponder,
      likedByUsers: likedByUsers ?? this.likedByUsers,
      replies: replies ?? this.replies,
    );
  }
}