import 'package:first_aid_health_care/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/user_profile.dart';
import '../models/emergency_contact.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/section_header.dart';
import 'auth_wrapper.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  UserProfile? _userProfile;
  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _dataService.getUserProfile();
      if (profile != null) {
        final contacts = await _dataService.getEmergencyContacts();
        if (!mounted) return;
        setState(() {
          _userProfile = profile;
          _emergencyContacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CustomSnackBar.show(
        context: context,
        message: 'Error loading profile: $e',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: _userProfile!),
      ),
    );

    if (result != null) {
      try {
        await _dataService.saveUserProfile(result);
        _loadUserProfile();
        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: 'Profile updated successfully',
          type: SnackBarType.success,
        );
      } catch (e) {
        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: 'Error saving profile: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? _buildLoadingIndicator()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  leading: Consumer<ThemeService>(
                    builder: (context, themeService, child) {
                      return IconButton(
                        icon: Icon(
                          themeService.isDarkMode
                              ? CupertinoIcons.moon_fill
                              : CupertinoIcons.sun_max_fill,
                          color: theme.colorScheme.onSurface,
                          size: 22,
                        ),
                        onPressed: () {
                          themeService.toggleTheme();
                        },
                      );
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildProfileHeader(),
                    title: Text(
                      _userProfile!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit, color: theme.colorScheme.onSurface),
                      onPressed: _editProfile,
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: theme.colorScheme.onSurface),
                      onPressed: () async {
                        final navigatorContext = context;
                        if (!navigatorContext.mounted) return;
                        final authService = AuthService();
                        await authService.signOut();
                        if (!navigatorContext.mounted) return;
                        Navigator.of(navigatorContext).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const AuthWrapper()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor:
                            theme.colorScheme.onSurfaceVariant,
                        indicatorColor: theme.colorScheme.primary,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Medical'),
                          Tab(text: 'Emergency'),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 252,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(),
                            _buildMedicalTab(),
                            _buildEmergencyTab(),
                          ],
                        ),
                      ),
                    ],
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
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading profile...',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: theme.colorScheme.onPrimary, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: Text(
                          _userProfile!.name.isNotEmpty
                              ? _userProfile!.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: theme.colorScheme.primary, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Profile Information',
            icon: Icons.person,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: 'Name',
                  value: _userProfile!.name,
                ),
                _buildInfoCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Age',
                  value: '${_userProfile!.age} years',
                ),
                _buildInfoCard(
                  icon: Icons.wc_outlined,
                  title: 'Gender',
                  value: _userProfile!.gender,
                ),
                if (_userProfile!.weight > 0)
                  _buildInfoCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Weight',
                    value: '${_userProfile!.weight} kg',
                  ),
                if (_userProfile!.height > 0)
                  _buildInfoCard(
                    icon: Icons.height_outlined,
                    title: 'Height',
                    value: '${_userProfile!.height} cm',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Medical Information',
            subtitle: 'Your health and medical details',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  icon: Icons.warning_outlined,
                  title: 'Allergies',
                  value: _userProfile!.allergies.isEmpty
                      ? 'None'
                      : _userProfile!.allergies.join(', '),
                ),
                _buildInfoCard(
                  icon: Icons.medication_outlined,
                  title: 'Medications',
                  value: _userProfile!.medications.isEmpty
                      ? 'None'
                      : _userProfile!.medications.join(', '),
                ),
                _buildInfoCard(
                  icon: Icons.healing_outlined,
                  title: 'Medical Conditions',
                  value: _userProfile!.medicalConditions.isEmpty
                      ? 'None'
                      : _userProfile!.medicalConditions.join(', '),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Emergency Contacts',
            subtitle: 'Your trusted emergency contacts',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_emergencyContacts.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.contact_phone_outlined,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No emergency contacts added',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _emergencyContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _emergencyContacts[index];
                      return _buildEmergencyContactCard(contact);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard(EmergencyContact contact) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withOpacity(0.15),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.2),
          width: 1.5,
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          contact.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (contact.isPrimaryContact) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Primary',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (contact.relationship.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        contact.relationship,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
