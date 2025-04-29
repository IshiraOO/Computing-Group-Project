import 'package:flutter/material.dart';
import '../models/illness.dart';
import '../services/data_service.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/screen_header.dart';
import 'illness_detail_screen.dart';

class IllnessDatabaseScreen extends StatefulWidget {
  const IllnessDatabaseScreen({super.key});

  @override
  State<IllnessDatabaseScreen> createState() => _IllnessDatabaseScreenState();
}

class _IllnessDatabaseScreenState extends State<IllnessDatabaseScreen> {
  final DataService _dataService = DataService();
  List<Illness> _illnesses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSeverityFilter = 'All';

  final List<String> _severityFilters = [
    'All',
    'Mild',
    'Moderate',
    'Severe',
    'Chronic',
    'Varies'
  ];

  @override
  void initState() {
    super.initState();
    _loadIllnesses();
  }

  Future<void> _loadIllnesses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final illnesses = await _dataService.getIllnesses();
      if (!mounted) return;
      setState(() {
        _illnesses = illnesses;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomSnackBar.show(
        context: context,
        message: 'Error loading illnesses: $e',
        type: SnackBarType.error,
      );
    }
  }

  List<Illness> get _filteredIllnesses {
    return _illnesses.where((illness) {
      final matchesSearch = _searchQuery.isEmpty ||
          illness.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          illness.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          illness.symptoms.any((symptom) =>
              symptom.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesSeverity = _selectedSeverityFilter == 'All' ||
          illness.severity.toLowerCase() == _selectedSeverityFilter.toLowerCase();

      return matchesSearch && matchesSeverity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Illness Database',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: _loadIllnesses,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Illness Database',
              subtitle: 'Comprehensive health information',
              icon: Icons.sick,
              cardTitle: 'Health Knowledge',
              cardSubtitle: 'Access detailed information about various illnesses and their treatments',
              cardIcon: Icons.healing,
            ),
            CustomSearchBar(
              hintText: 'Search illnesses, symptoms...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            ),
            _buildFilterSection(context),
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _filteredIllnesses.isEmpty
                      ? _buildEmptyState()
                      : _buildIllnessesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Severity',
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
              children: _severityFilters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: _selectedSeverityFilter == filter
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: _selectedSeverityFilter == filter
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: _selectedSeverityFilter == filter,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSeverityFilter = filter;
                        });
                      }
                    },
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
            'Loading illnesses...',
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
            'No illnesses found',
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

  Widget _buildIllnessesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredIllnesses.length,
      itemBuilder: (context, index) {
        final illness = _filteredIllnesses[index];
        return _buildIllnessCard(illness);
      },
    );
  }

  Widget _buildIllnessCard(Illness illness) {
    final theme = Theme.of(context);
    Color cardColor;
    IconData illnessIcon;
    Color iconColor;
    Color iconBackgroundColor;

    switch (illness.severity.toLowerCase()) {
      case 'severe':
        cardColor = theme.colorScheme.error.withOpacity(0.1);
        illnessIcon = Icons.warning_rounded;
        iconColor = theme.colorScheme.error;
        iconBackgroundColor = theme.colorScheme.error.withOpacity(0.1);
        break;
      case 'moderate':
        cardColor = theme.colorScheme.tertiary.withOpacity(0.1);
        illnessIcon = Icons.warning_amber_rounded;
        iconColor = theme.colorScheme.tertiary;
        iconBackgroundColor = theme.colorScheme.tertiary.withOpacity(0.1);
        break;
      case 'chronic':
        cardColor = theme.colorScheme.primary.withOpacity(0.1);
        illnessIcon = Icons.timer;
        iconColor = theme.colorScheme.primary;
        iconBackgroundColor = theme.colorScheme.primary.withOpacity(0.1);
        break;
      default:
        cardColor = theme.colorScheme.secondary.withOpacity(0.1);
        illnessIcon = Icons.healing;
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
                builder: (context) => IllnessDetailScreen(illness: illness),
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
                        illnessIcon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        illness.name,
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
                  illness.description,
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
                            Icons.sick,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${illness.symptoms.length} symptoms',
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
                        illness.severity,
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

