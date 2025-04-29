import 'package:first_aid_health_care/screens/training_module_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/training_module.dart';
import '../services/training_module_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/screen_header.dart';

class TrainingModulesScreen extends StatefulWidget {
  const TrainingModulesScreen({super.key});

  @override
  State<TrainingModulesScreen> createState() => _TrainingModulesScreenState();
}

class _TrainingModulesScreenState extends State<TrainingModulesScreen> with SingleTickerProviderStateMixin {
  List<TrainingModule> _modules = [];
  List<String> _roles = [];
  bool _isLoading = true;
  late TabController _tabController;
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadRolesAndModules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRolesAndModules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load available roles
      final roles = await TrainingModuleService.getAvailableRoles();
      roles.insert(0, 'all'); // Add 'all' as the first option

      // Load all modules
      final modules = await TrainingModuleService.fetchAllModules();

      if (!mounted) return;
      setState(() {
        _roles = roles;
        _modules = modules;
        _tabController = TabController(length: roles.length, vsync: this);
        _tabController.addListener(_handleTabSelection);
      });
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Error loading training modules: $e',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedRole = _roles[_tabController.index];
      });
    }
  }

  List<TrainingModule> get _filteredModules {
    if (_selectedRole == 'all') {
      return _modules;
    } else {
      return _modules.where((module) => module.targetRole == _selectedRole).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Training Modules',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadRolesAndModules();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingIndicator()
            : Column(
              children: [
                ScreenHeader(
                  title: 'Training Modules',
                  subtitle: 'Learn essential first aid skills',
                  icon: Icons.school,
                  cardTitle: 'First Aid Training',
                  cardSubtitle: 'Access interactive modules to build your emergency response skills',
                  cardIcon: Icons.medical_services,
                ),
                _buildRoleTabs(theme),
                Expanded(
                  child: _filteredModules.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildModulesList(theme),
                ),
              ],
            ),
        ),
    );
  }

  Widget _buildRoleTabs(ThemeData theme) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        dividerColor: Colors.transparent,
        tabs: _roles.map((role) {
          return Tab(
            text: role == 'all' ? 'All Modules' : _capitalizeRole(role),
          );
        }).toList(),
      ),
    );
  }

  String _capitalizeRole(String role) {
    return role.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No training modules available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedRole == 'all'
                ? 'Check back later for new training content'
                : 'No modules available for ${_capitalizeRole(_selectedRole)}',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModulesList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredModules.length,
      itemBuilder: (context, index) {
        final module = _filteredModules[index];
        return _buildModuleCard(module, theme);
      },
    );
  }

  Widget _buildModuleCard(TrainingModule module, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToModuleDetail(module),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: module.imageUrl.isNotEmpty
                  ? Image.network(
                      module.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage(theme, 150);
                      },
                    )
                  : _buildPlaceholderImage(theme, 150),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(_capitalizeRole(module.targetRole)),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                      ),
                      Chip(
                        label: Text(module.difficulty),
                        backgroundColor: _getDifficultyColor(module.difficulty, theme),
                        labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${module.estimatedTimeMinutes} min',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      CustomButton(
                        text: 'Start Training',
                        onPressed: () => _navigateToModuleDetail(module),
                        type: ButtonType.primary,
                        icon: Icons.play_arrow,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ThemeData theme, double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.school,
          size: 50,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return theme.colorScheme.primaryContainer;
      case 'intermediate':
        return theme.colorScheme.secondaryContainer;
      case 'advanced':
        return theme.colorScheme.tertiaryContainer;
      default:
        return theme.colorScheme.primaryContainer;
    }
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
            'Loading training modules...',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToModuleDetail(TrainingModule module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingModuleDetailScreen(module: module),
      ),
    );
  }
}