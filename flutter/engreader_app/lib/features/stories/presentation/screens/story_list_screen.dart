import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../story/presentation/providers/story_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

class StoryListScreen extends ConsumerStatefulWidget {
  const StoryListScreen({super.key});

  @override
  ConsumerState<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends ConsumerState<StoryListScreen> {
  int _selectedIndex = 0;

  void _onNavigationTap(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        // Already on stories
        break;
      case 1:
        context.go('/progress');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final storiesAsync = ref.watch(storyListProvider(null));
    final progressAsync = ref.watch(progressProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Logout action
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(storyListProvider);
          ref.invalidate(progressProvider);
        },
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'Ready to read?',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      progressAsync.when(
                        data: (progress) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: theme.colorScheme.secondary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${progress.currentStreak}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: theme.colorScheme.secondary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '0',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Generate Story Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/stories/generate'),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate New Story'),
            ),
          ),
          const SizedBox(height: 24),
          
          // Stories Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Stories',
                style: theme.textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  // TODO: Show all stories
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Stories List
          storiesAsync.when(
            data: (stories) {
              if (stories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stories yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generate your first personalized story',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Column(
                children: stories.map((story) => _buildStoryCard(context, story)).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load stories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(storyListProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigationTap,
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

  Widget _buildStoryCard(BuildContext context, dynamic story) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.go('/stories/${story.id}/read');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      story.cefrLevelString,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      story.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (story.isCompleted == true)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                story.content != null && story.content!.length > 100
                    ? '${story.content!.substring(0, 100)}...'
                    : story.content ?? story.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${story.wordCount} words',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(story.wordCount / 150).ceil()} min',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (story.topic != null) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '📚 ${story.topic}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
