import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final String postId;

  const CommunityPostDetailScreen({super.key, required this.postId});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final TextEditingController _responseController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;
  final bool _isLoadingPost = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.getCurrentUser()?.uid;
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _addResponse() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a response')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to respond')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      await CommunityService.addResponse(
        postId: widget.postId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Anonymous',
        userPhotoUrl: currentUser.photoURL ?? '',
        content: _responseController.text.trim(),
      );

      if (!mounted) return;
      _responseController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response added successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding response: $e')),
      );
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _likePost(CommunityPost post) async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to like posts')),
        );
        return;
      }

      await CommunityService.likePost(post.id, currentUser.uid);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error liking post: $e')),
      );
    }
  }

  Future<void> _markAsResolved() async {
    try {
      await CommunityService.markPostAsResolved(widget.postId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post marked as resolved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking post as resolved: $e')),
      );
    }
  }

  void _showAddReplyDialog(String responseId, String responderName) {
    final TextEditingController replyController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text('Reply to $responderName'),
            content: TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Write your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (replyController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('Please enter a reply')),
                          );
                          return;
                        }

                        setState(() {
                          isSubmitting = true;
                        });

                        try {
                          final currentUser = _authService.getCurrentUser();
                          if (currentUser == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('You must be logged in to reply')),
                            );
                            return;
                          }

                          await CommunityService.addReply(
                            postId: widget.postId,
                            responseId: responseId,
                            userId: currentUser.uid,
                            userName: currentUser.displayName ?? 'Anonymous',
                            userPhotoUrl: currentUser.photoURL ?? '',
                            content: replyController.text.trim(),
                          );

                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('Reply added successfully')),
                          );
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('Error adding reply: $e')),
                          );
                        }

                        if (dialogContext.mounted) {
                          setState(() {
                            isSubmitting = false;
                          });
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Community Post',
        showBackButton: true,
      ),
      body: StreamBuilder<CommunityPost?>(
        stream: CommunityService.getPostById(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading post: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Post not found'));
          }

          final post = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPostHeader(context, post),
                      _buildPostContent(context, post),
                      _buildPostActions(context, post),
                      _buildResponsesList(context, post),
                    ],
                  ),
                ),
              ),
              _buildResponseInput(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context, CommunityPost post) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: post.userPhotoUrl.isNotEmpty
                    ? NetworkImage(post.userPhotoUrl)
                    : null,
                child: post.userPhotoUrl.isEmpty
                    ? Text(
                        post.userName.isNotEmpty
                            ? post.userName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      dateFormat.format(post.timestamp),
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (post.isEmergency)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emergency,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Emergency',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (post.isResolved) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Resolved',
                    style: TextStyle(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostContent(BuildContext context, CommunityPost post) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        post.imageUrls[index],
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.error_outline),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostActions(BuildContext context, CommunityPost post) {
    final theme = Theme.of(context);
    final isCurrentUserAuthor = post.userId == _currentUserId;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _likePost(post),
                    icon: Icon(
                      post.likedByUsers.contains(_currentUserId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: post.likedByUsers.contains(_currentUserId)
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${post.likedByUsers.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.comment_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.responses.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (isCurrentUserAuthor && !post.isResolved)
                CustomButton(
                  text: 'Mark as Resolved',
                  onPressed: _markAsResolved,
                  type: ButtonType.outline,
                  icon: Icons.check_circle_outline,
                  height: 36,
                ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildResponsesList(BuildContext context, CommunityPost post) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    if (post.responses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.forum_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'No responses yet',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to respond!',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: post.responses.length,
      itemBuilder: (context, index) {
        final response = post.responses[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResponseItem(context, response, dateFormat),
            if (response.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: response.replies.length,
                  itemBuilder: (context, replyIndex) {
                    final reply = response.replies[replyIndex];
                    return _buildResponseItem(
                      context,
                      reply,
                      dateFormat,
                      isReply: true,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildResponseItem(
    BuildContext context,
    CommunityResponse response,
    DateFormat dateFormat, {
    bool isReply = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isReply ? 8 : 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 16 : 20,
            backgroundImage: response.userPhotoUrl.isNotEmpty
                ? NetworkImage(response.userPhotoUrl)
                : null,
            child: response.userPhotoUrl.isEmpty
                ? Text(
                    response.userName.isNotEmpty
                        ? response.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isReply ? 12 : 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      response.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isReply ? 14 : 16,
                      ),
                    ),
                    if (response.isVerifiedResponder) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: isReply ? 14 : 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Responder',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: isReply ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  response.content,
                  style: TextStyle(
                    fontSize: isReply ? 14 : 16,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                if (response.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: isReply ? 100 : 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: response.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              response.imageUrls[index],
                              height: isReply ? 100 : 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: isReply ? 100 : 150,
                                  height: isReply ? 100 : 150,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: Icon(Icons.error_outline),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      dateFormat.format(response.timestamp),
                      style: TextStyle(
                        fontSize: isReply ? 10 : 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (!isReply)
                      TextButton.icon(
                        onPressed: () => _showAddReplyDialog(
                          response.id,
                          response.userName,
                        ),
                        icon: Icon(
                          Icons.reply,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _responseController,
              maxLines: 4,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Write a response...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSubmitting ? null : _addResponse,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}