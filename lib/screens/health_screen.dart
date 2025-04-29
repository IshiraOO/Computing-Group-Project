import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/section_header.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Health',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHealthOverview(context),
              const SectionHeader(
                title: 'Health Resources',
                subtitle: 'Access essential health information',
              ),
              _buildHealthResources(context),
              const SectionHeader(
                title: 'Health Tracking',
                subtitle: 'Monitor your health and wellness',
              ),
              _buildHealthTracking(context),
              const SectionHeader(
                title: 'Community',
                subtitle: 'Connect with others and share experiences',
              ),
              _buildCommunityFeatures(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthOverview(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHealthMetric(
                context,
                label: 'Steps',
                value: '8,234',
                icon: Icons.directions_walk,
                color: theme.colorScheme.primary,
              ),
              _buildHealthMetric(
                context,
                label: 'Heart Rate',
                value: '72',
                unit: 'bpm',
                icon: Icons.favorite,
                color: theme.colorScheme.error,
              ),
              _buildHealthMetric(
                context,
                label: 'Sleep',
                value: '7.5',
                unit: 'hrs',
                icon: Icons.bedtime,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(
    BuildContext context, {
    required String label,
    required String value,
    String? unit,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (unit != null) ...[
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthResources(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildResourceCard(
            context,
            title: 'Illness Database',
            subtitle: 'Information about common illnesses and conditions',
            icon: Icons.sick,
            onTap: () => Navigator.pushNamed(context, '/illness-database'),
          ),
          const SizedBox(height: 12),
          _buildResourceCard(
            context,
            title: 'Training Modules',
            subtitle: 'Learn essential health care skills',
            icon: Icons.school,
            onTap: () => Navigator.pushNamed(context, '/training-modules'),
          ),
          const SizedBox(height: 12),
          _buildResourceCard(
            context,
            title: 'Symptom Analysis',
            subtitle: 'AI-powered symptom assessment',
            icon: Icons.health_and_safety,
            onTap: () => Navigator.pushNamed(context, '/symptom-analysis'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTracking(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildResourceCard(
            context,
            title: 'Health Journal',
            subtitle: 'Track your health and symptoms',
            icon: Icons.note_alt,
            onTap: () => Navigator.pushNamed(context, '/health-journal'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildResourceCard(
            context,
            title: 'Community Support',
            subtitle: 'Connect with others and share experiences',
            icon: Icons.forum,
            onTap: () => Navigator.pushNamed(context, '/community-support'),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
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
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}