import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/custom_card.dart';
import '../screens/main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'First Aid Health Care',
        showBackButton: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              SizedBox(
                height: 156,
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildHeaderCard(
                          context,
                          title: 'Emergency Guide',
                          subtitle: 'Step-by-step emergency response protocols and life-saving techniques',
                          icon: Icons.health_and_safety,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Health Library',
                          subtitle: 'Extensive medical condition library with detailed symptoms and treatments',
                          icon: Icons.medical_services,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Smart Care Plans',
                          subtitle: 'Customized healthcare plans based on individual health profiles',
                          icon: Icons.healing,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Always Available',
                          subtitle: 'Access critical health information without internet connection',
                          icon: Icons.offline_bolt,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Rapid Response',
                          subtitle: 'Instant alerts to emergency contacts and nearby medical responders',
                          icon: Icons.emergency,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Find Help Nearby',
                          subtitle: 'Real-time mapping of nearby medical facilities and emergency rooms',
                          icon: Icons.location_on,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Smart Diagnosis',
                          subtitle: 'Advanced algorithms for preliminary health assessment',
                          icon: Icons.psychology,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Expert Training',
                          subtitle: 'Specialized training programs for different healthcare roles',
                          icon: Icons.school,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Health Diary',
                          subtitle: 'Secure personal health record management with offline capabilities',
                          icon: Icons.book,
                        ),
                        _buildHeaderCard(
                          context,
                          title: 'Community Care',
                          subtitle: 'Connect with healthcare professionals and community members',
                          icon: Icons.people,
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(10, (index) {
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: _currentPage == index
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary
                                        .withOpacity(0.3),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SectionHeader(
                title: 'Quick Actions',
                subtitle: 'Access essential features quickly',
              ),
              _buildQuickActions(context),
              const SectionHeader(
                title: 'Recent Activity',
                subtitle: 'Your recent health activities',
              ),
              _buildRecentActivity(context),
              const SectionHeader(
                title: 'Health Tips',
                subtitle: 'Daily health and wellness advice',
              ),
              _buildHealthTips(context),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Health Companion',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      const MainNavigationScreen(initialIndex: 3),
                ),
              ),
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                context,
                label: 'Emergency',
                icon: Icons.emergency,
                backgroundColor: theme.colorScheme.error,
                onPressed: () {
                  final mainNav = context.findAncestorStateOfType<MainNavigationScreenState>();
                  if (mainNav != null) {
                    mainNav.switchTab(1);
                  }
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Health',
                icon: Icons.medical_services,
                backgroundColor: theme.colorScheme.primary,
                onPressed: () {
                  final mainNav = context.findAncestorStateOfType<MainNavigationScreenState>();
                  if (mainNav != null) {
                    mainNav.switchTab(2);
                  }
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Profile',
                icon: Icons.person,
                backgroundColor: theme.colorScheme.tertiary,
                onPressed: () {
                  final mainNav = context.findAncestorStateOfType<MainNavigationScreenState>();
                  if (mainNav != null) {
                    mainNav.switchTab(3);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20.0),
        child: Ink(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor.withOpacity(0.15),
                backgroundColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: backgroundColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: backgroundColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: backgroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildActivityCard(
            context,
            title: 'Last Health Check',
            subtitle: 'Blood pressure and heart rate recorded',
            icon: Icons.favorite,
            time: '2 hours ago',
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            context,
            title: 'Medication Taken',
            subtitle: 'Morning medication completed',
            icon: Icons.medication,
            time: '4 hours ago',
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            context,
            title: 'Exercise Completed',
            subtitle: '30 minutes of walking',
            icon: Icons.directions_walk,
            time: '6 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String time,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
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
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTips(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildTipCard(
            context,
            title: 'Stay Hydrated',
            subtitle: 'Drink at least 8 glasses of water daily',
            icon: Icons.water_drop,
            color: theme.colorScheme.scrim,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            title: 'Regular Exercise',
            subtitle: '30 minutes of daily physical activity',
            icon: Icons.fitness_center,
            color: theme.colorScheme.surfaceContainer,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            context,
            title: 'Healthy Diet',
            subtitle: 'Eat a balanced diet with fruits and vegetables',
            icon: Icons.restaurant,
            color: theme.colorScheme.inverseSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
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
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: color,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: CustomCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
