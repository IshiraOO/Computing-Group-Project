import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/community_post.dart';

class CommunityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String postsCollection = 'community_posts';
  static const String responsesCollection = 'community_responses';
  static const String userVerificationsCollection = 'user_verifications';
  static const Uuid _uuid = Uuid();

  // Create a new community post
  static Future<CommunityPost> createPost({
    required String userId,
    required String userName,
    String userPhotoUrl = '',
    required String title,
    required String content,
    List<String> tags = const [],
    List<String> imageUrls = const [],
    bool isEmergency = false,
  }) async {
    final postId = _uuid.v4();
    final timestamp = DateTime.now();

    final post = CommunityPost(
      id: postId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      timestamp: timestamp,
      title: title,
      content: content,
      tags: tags,
      imageUrls: imageUrls,
      isEmergency: isEmergency,
    );

    await _firestore.collection(postsCollection).doc(postId).set(post.toJson());
    return post;
  }

  // Get all community posts
  static Stream<List<CommunityPost>> getAllPosts() {
    return _firestore
        .collection(postsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityPost.fromJson(doc.data());
      }).toList();
    });
  }

  // Get emergency posts
  static Stream<List<CommunityPost>> getEmergencyPosts() {
    return _firestore
        .collection(postsCollection)
        .where('isEmergency', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityPost.fromJson(doc.data());
      }).toList();
    });
  }

  // Get posts by tag
  static Stream<List<CommunityPost>> getPostsByTag(String tag) {
    return _firestore
        .collection(postsCollection)
        .where('tags', arrayContains: tag)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityPost.fromJson(doc.data());
      }).toList();
    });
  }

  // Get posts by user
  static Stream<List<CommunityPost>> getPostsByUser(String userId) {
    return _firestore
        .collection(postsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityPost.fromJson(doc.data());
      }).toList();
    });
  }

  // Get a single post by ID
  static Stream<CommunityPost?> getPostById(String postId) {
    return _firestore
        .collection(postsCollection)
        .doc(postId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return CommunityPost.fromJson(doc.data()!);
      } else {
        return null;
      }
    });
  }

  // Add a response to a post
  static Future<CommunityResponse> addResponse({
    required String postId,
    required String userId,
    required String userName,
    String userPhotoUrl = '',
    required String content,
    List<String> imageUrls = const [],
  }) async {
    final responseId = _uuid.v4();
    final timestamp = DateTime.now();

    final response = CommunityResponse(
      id: responseId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      timestamp: timestamp,
      content: content,
      imageUrls: imageUrls,
    );

    // Get the current post
    final postDoc = await _firestore.collection(postsCollection).doc(postId).get();
    if (!postDoc.exists) {
      throw Exception('Post not found');
    }

    final post = CommunityPost.fromJson(postDoc.data()!);
    final updatedResponses = [...post.responses, response];

    // Update the post with the new response
    await _firestore.collection(postsCollection).doc(postId).update({
      'responses': updatedResponses.map((r) => r.toJson()).toList(),
    });

    return response;
  }

  // Add a reply to a response
  static Future<CommunityResponse> addReply({
    required String postId,
    required String responseId,
    required String userId,
    required String userName,
    String userPhotoUrl = '',
    required String content,
    List<String> imageUrls = const [],
  }) async {
    final replyId = _uuid.v4();
    final timestamp = DateTime.now();

    final reply = CommunityResponse(
      id: replyId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      timestamp: timestamp,
      content: content,
      imageUrls: imageUrls,
    );

    // Get the current post
    final postDoc = await _firestore.collection(postsCollection).doc(postId).get();
    if (!postDoc.exists) {
      throw Exception('Post not found');
    }

    final post = CommunityPost.fromJson(postDoc.data()!);

    // Find the response to reply to
    final updatedResponses = post.responses.map((response) {
      if (response.id == responseId) {
        // Add the reply to this response
        final updatedReplies = [...response.replies, reply];
        return response.copyWith(replies: updatedReplies);
      }
      return response;
    }).toList();

    // Update the post with the new reply
    await _firestore.collection(postsCollection).doc(postId).update({
      'responses': updatedResponses.map((r) => r.toJson()).toList(),
    });

    return reply;
  }

  // Mark a post as resolved
  static Future<void> markPostAsResolved(String postId) async {
    await _firestore.collection(postsCollection).doc(postId).update({
      'isResolved': true,
    });
  }

  // Like a post
  static Future<void> likePost(String postId, String userId) async {
    final postDoc = await _firestore.collection(postsCollection).doc(postId).get();
    if (!postDoc.exists) {
      throw Exception('Post not found');
    }

    final post = CommunityPost.fromJson(postDoc.data()!);
    final likedByUsers = [...post.likedByUsers];

    if (likedByUsers.contains(userId)) {
      // Unlike if already liked
      likedByUsers.remove(userId);
    } else {
      // Like if not already liked
      likedByUsers.add(userId);
    }

    await _firestore.collection(postsCollection).doc(postId).update({
      'likedByUsers': likedByUsers,
    });
  }

  // Check if a user is a verified responder
  static Future<bool> isVerifiedResponder(String userId) async {
    final verificationDoc = await _firestore
        .collection(userVerificationsCollection)
        .doc(userId)
        .get();

    return verificationDoc.exists && verificationDoc.data()?['isVerified'] == true;
  }

  // Delete a post
  static Future<void> deletePost(String postId) async {
    await _firestore.collection(postsCollection).doc(postId).delete();
  }

  // Search posts by keyword
  static Future<List<CommunityPost>> searchPosts(String keyword) async {
    // Search in title and content
    final titleResults = await _firestore
        .collection(postsCollection)
        .where('title', isGreaterThanOrEqualTo: keyword)
        .where('title', isLessThanOrEqualTo: '$keyword\u{f8ff}')
        .get();

    final contentResults = await _firestore
        .collection(postsCollection)
        .where('content', isGreaterThanOrEqualTo: keyword)
        .where('content', isLessThanOrEqualTo: '$keyword\u{f8ff}')
        .get();

    // Combine results and remove duplicates
    final Map<String, CommunityPost> combinedResults = {};

    for (var doc in titleResults.docs) {
      combinedResults[doc.id] = CommunityPost.fromJson(doc.data());
    }

    for (var doc in contentResults.docs) {
      combinedResults[doc.id] = CommunityPost.fromJson(doc.data());
    }

    return combinedResults.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}