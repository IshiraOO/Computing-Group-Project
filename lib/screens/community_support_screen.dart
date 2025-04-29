import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/screen_header.dart';

class CommunitySupportScreen extends StatefulWidget {
  const CommunitySupportScreen({super.key});

  @override
  State<CommunitySupportScreen> createState() => _CommunitySupportScreenState();
}

class _CommunitySupportScreenState extends State<CommunitySupportScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<CommunityPost> _filteredPosts = [];
  String _selectedTag = 'All';
  bool _isLoading = true;
  bool _isSearching = false;

  final List<String> _availableTags = [
    'All',
    'Emergency',
    'First Aid',
    'Medical Advice',
    'Mental Health',
    'Chronic Conditions',
    'Medications',
    'Recovery',
    'Wellness',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    // Reset search state
    _isSearching = false;
    _searchController.clear();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _searchPosts(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return _loadPosts();
    }

    setState(() {
      _isLoading = true;
      _isSearching = true;
    });

    try {
      final posts = await CommunityService.searchPosts(keyword);
      if (!mounted) return;
      setState(() {
        _filteredPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Error searching posts: $e',
        type: SnackBarType.error,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterByTag(String tag) {
    setState(() {
      _selectedTag = tag;
      _isSearching = false;
      _searchController.clear();
    });
    _loadPosts();
  }

  void _navigateToPostDetail(CommunityPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityPostDetailScreen(postId: post.id),
      ),
    ).then((_) => _loadPosts());
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCommunityPostScreen(),
      ),
    ).then((_) => _loadPosts());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Community Support',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _isSearching = false;
                _searchController.clear();
              });
              _loadPosts();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Community Support',
              subtitle: 'Connect with others for health advice',
              icon: Icons.forum_outlined,
              cardTitle: 'Join the Conversation',
              cardSubtitle: 'Share experiences and get support from the community',
              cardIcon: Icons.people_alt_outlined,
            ),
            _buildSearchAndFilter(context),
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'All Posts'),
              Tab(text: 'Emergency'),
              Tab(text: 'My Posts'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsList(context, 'all'),
                _buildPostsList(context, 'emergency'),
                _buildPostsList(context, 'my_posts'),
              ],
            ),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSearchBar(
            hintText: 'Search community posts...',
            onChanged: _searchPosts,
            margin: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          Text(
            'Filter by Tags',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => _filterByTag(tag),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, String type) {
    return StreamBuilder<List<CommunityPost>>(
      stream: _getPostsStream(type),
      builder: (context, snapshot) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_isSearching) {
          return _buildSearchResults(context);
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading posts: ${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Create a Post',
                  onPressed: _navigateToCreatePost,
                  type: ButtonType.primary,
                  icon: Icons.add,
                ),
              ],
            ),
          );
        }

        final posts = _filterPostsByTag(snapshot.data!);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return _buildPostCard(context, posts[index]);
          },
        );
      },
    );
  }

  Stream<List<CommunityPost>> _getPostsStream(String type) {
    switch (type) {
      case 'emergency':
        return CommunityService.getEmergencyPosts();
      case 'my_posts':
        // Assuming we have the current user's ID
        final currentUserId = _authService.getCurrentUser()?.uid ?? '';
        return CommunityService.getPostsByUser(currentUserId);
      case 'all':
      default:
        if (_selectedTag != 'All' && _selectedTag != 'Emergency') {
          return CommunityService.getPostsByTag(_selectedTag);
        } else {
          return CommunityService.getAllPosts();
        }
    }
  }

  List<CommunityPost> _filterPostsByTag(List<CommunityPost> posts) {
    if (_selectedTag == 'All') {
      return posts;
    } else if (_selectedTag == 'Emergency') {
      return posts.where((post) => post.isEmergency).toList();
    } else {
      return posts.where((post) => post.tags.contains(_selectedTag)).toList();
    }
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(context, _filteredPosts[index]);
      },
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityPost post) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToPostDetail(post),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post.userPhotoUrl.isNotEmpty
                        ? NetworkImage(post.userPhotoUrl)
                        : null,
                    child: post.userPhotoUrl.isEmpty
                        ? Text(
                            post.userName.isNotEmpty
                                ? post.userName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                            fontSize: 12,
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
              const SizedBox(height: 12),
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.viewCount}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.responses.length}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        post.likedByUsers.contains(_authService.getCurrentUser()?.uid ?? '')
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: post.likedByUsers.contains(_authService.getCurrentUser()?.uid ?? '')
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likedByUsers.length}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      if (post.isResolved) ...[
                        const SizedBox(width: 16),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This screen will be implemented separately
class CommunityPostDetailScreen extends StatelessWidget {
  final String postId;

  const CommunityPostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Post Details',
        showBackButton: true,
      ),
      body: Center(
        child: Text('Post Detail Screen for ID: $postId'),
      ),
    );
  }
}

// This screen will be implemented separately
class CreateCommunityPostScreen extends StatelessWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Create Post',
        showBackButton: true,
      ),
      body: const Center(
        child: Text('Create Post Screen'),
      ),
    );
  }
}