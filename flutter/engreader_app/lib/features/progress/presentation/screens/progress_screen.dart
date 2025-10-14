import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(progressProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(progressProvider),
          ),
        ],
      ),
      body: progressAsync.when(
        data: (progress) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Current Level Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Current Level',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          progress.currentCefrLevel ?? 'A1',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getLevelDescription(progress.currentCefrLevel ?? 'A1'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    Icons.menu_book,
                    'Stories Read',
                    '${progress.totalStoriesRead}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    Icons.quiz,
                    'Quizzes',
                    '${progress.totalQuizzesTaken}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    Icons.local_fire_department,
                    'Streak',
                    '${progress.currentStreak} days',
                    theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    Icons.star,
                    'Avg Score',
                    '${progress.averageQuizScore.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Coming Soon
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Detailed Analytics Coming Soon',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Charts, achievements, and more!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load progress',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(progressProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            context.go('/stories');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case 'A1':
        return 'Beginner';
      case 'A2':
        return 'Elementary';
      case 'B1':
        return 'Intermediate';
      case 'B2':
        return 'Upper-Intermediate';
      case 'C1':
        return 'Advanced';
      case 'C2':
        return 'Proficient';
      default:
        return 'Unknown';
    }
  }

  Widget _buildStatCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value, [
    Color? iconColor,
  ]) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
