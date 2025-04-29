import 'package:flutter/material.dart';
import '../models/first_aid_instruction.dart';
import '../services/data_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/screen_header.dart';
import 'first_aid_detail_screen.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  final DataService _dataService = DataService();
  List<FirstAidInstruction> _instructions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFirstAidInstructions();
  }

  Future<void> _loadFirstAidInstructions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final instructions = await _dataService.getFirstAidInstructions();
      if (!mounted) return;
      setState(() {
        _instructions = instructions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomSnackBar.show(
        context: context,
        message: 'Error loading first aid instructions: $e',
        type: SnackBarType.error,
      );
    }
  }

  List<FirstAidInstruction> get _filteredInstructions {
    if (_searchQuery.isEmpty) {
      return _instructions;
    }
    return _instructions.where((instruction) {
      return instruction.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          instruction.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'First Aid Guide',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _loadFirstAidInstructions,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'First Aid Guide',
              subtitle: 'Emergency medical instructions',
              icon: Icons.medical_services,
              cardTitle: 'Emergency Ready',
              cardSubtitle: 'Learn essential first aid skills to handle emergencies with confidence',
              cardIcon: Icons.health_and_safety,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchBar(
                    hintText: 'Search first aid instructions...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _filteredInstructions.isEmpty
                      ? _buildEmptyState()
                      : _buildInstructionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading first aid instructions...',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No first aid instructions found',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: _filteredInstructions.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final instruction = _filteredInstructions[index];
        return _buildFirstAidCard(instruction);
      },
    );
  }

  Widget _buildFirstAidCard(FirstAidInstruction instruction) {
    final theme = Theme.of(context);
    Color cardColor;
    IconData emergencyIcon;
    Color iconColor;
    Color iconBackgroundColor;

    // Set color and icon based on emergency level
    switch (instruction.emergencyLevel) {
      case 'high':
        cardColor = theme.colorScheme.error.withOpacity(0.1);
        emergencyIcon = Icons.warning_rounded;
        iconColor = theme.colorScheme.error;
        iconBackgroundColor = theme.colorScheme.error.withOpacity(0.1);
        break;
      case 'medium':
        cardColor = theme.colorScheme.tertiary.withOpacity(0.1);
        emergencyIcon = Icons.warning_amber_rounded;
        iconColor = theme.colorScheme.tertiary;
        iconBackgroundColor = theme.colorScheme.tertiary.withOpacity(0.1);
        break;
      default: // 'low'
        cardColor = theme.colorScheme.secondary.withOpacity(0.1);
        emergencyIcon = Icons.info_outline;
        iconColor = theme.colorScheme.secondary;
        iconBackgroundColor = theme.colorScheme.secondary.withOpacity(0.1);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor,
            cardColor.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FirstAidDetailScreen(instruction: instruction),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Icon(
                        emergencyIcon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        instruction.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  instruction.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.video_library,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Video tutorial',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${instruction.steps.length} steps',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}