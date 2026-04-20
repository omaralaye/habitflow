import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../services/theme_service.dart';
import '../services/database_service.dart';
import '../widgets/state_widgets.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Map<String, dynamic>>> _allMilestonesFuture;

  @override
  void initState() {
    super.initState();
    _allMilestonesFuture = DatabaseService().getAllMilestones();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.primaryLighter,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: DatabaseService().profileStream,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingWidget(message: 'Loading profile...');
          }
          if (profileSnapshot.hasError) {
            return AppErrorWidget(
              message: 'Failed to load profile data.',
              onRetry: () {
                setState(() {});
              },
            );
          }

          final profile = profileSnapshot.data;
          if (profile == null) {
             return const AppErrorWidget(message: 'Profile not found.');
          }

          final int level = profile['level'] ?? 1;
          final int xp = profile['xp'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfileCard(context, profile),
                const SizedBox(height: 24),
                _buildMilestones(context),
                const SizedBox(height: 24),
                _buildGlobalRank(context, level, xp),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, Map<String, dynamic> profile) {
    final theme = Theme.of(context);
    final isDark = ThemeService().isDarkMode;

    final String name = profile['name'] ?? 'User';
    final String emoji = profile['emoji'] ?? '🦊';
    final int level = profile['level'] ?? 1;
    final int xp = profile['xp'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.bgLavender,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 4),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level $level Habit Master',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          _buildXPProgress(context, xp, level),
        ],
      ),
    );
  }

  Widget _buildXPProgress(BuildContext context, int xp, int level) {
    final nextLevelXp = level * 500;
    final progress = xp / nextLevelXp;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'XP Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '$xp / $nextLevelXp XP',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.primaryLighter,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildMilestones(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milestones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _allMilestonesFuture,
            builder: (context, allSnapshot) {
              if (allSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (allSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load milestones.',
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                  ),
                );
              }

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: DatabaseService().userMilestonesStream,
                builder: (context, unlockedSnapshot) {
                  final allMilestones = allSnapshot.data ?? [];
                  final unlockedMilestones = unlockedSnapshot.data ?? [];
                  final unlockedIds = unlockedMilestones.map((m) => m['id']).toSet();

                  if (allMilestones.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No milestones available yet.'),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allMilestones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final milestone = allMilestones[index];
                      final isUnlocked = unlockedIds.contains(milestone['id']);
                      return _buildMilestoneItem(
                        context,
                        milestone['title'] ?? '',
                        milestone['description'] ?? '',
                        milestone['emoji'] ?? '⭐',
                        isUnlocked,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(
    BuildContext context,
    String title,
    String description,
    String emoji,
    bool isCompleted,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.accentGreen.withOpacity(0.1) : AppColors.textGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
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
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? theme.colorScheme.onSurface : AppColors.textGrey,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
        if (isCompleted)
          const Icon(
            Icons.check_circle,
            color: AppColors.accentGreen,
            size: 24,
          ),
      ],
    );
  }

  Widget _buildGlobalRank(BuildContext context, int level, int xp) {
    final theme = Theme.of(context);

    // Mock rank calculation based on level and XP
    final int rank = 10000 - (level * 100 + xp ~/ 5);
    final String percentage = (100 - (level * 2 + xp / 500)).clamp(1, 99).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Rank',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 70,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top $percentage% of Habit Masters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Keep up the great work!',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
