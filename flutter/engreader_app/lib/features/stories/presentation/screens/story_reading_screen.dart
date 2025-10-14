import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../story/presentation/providers/story_provider.dart';
import '../../../story/data/models/story_model.dart';
import '../../../translation/presentation/providers/translation_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'dart:async';

class StoryReadingScreen extends ConsumerStatefulWidget {
  final String storyId;
  
  const StoryReadingScreen({
    super.key,
    required this.storyId,
  });

  @override
  ConsumerState<StoryReadingScreen> createState() => _StoryReadingScreenState();
}

class _StoryReadingScreenState extends ConsumerState<StoryReadingScreen> {
  String? _selectedWord;
  String? _selectedSentence;
  bool _showTranslation = false;
  DateTime? _readingStartTime;
  Timer? _readingTimer;
  int _readingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _readingStartTime = DateTime.now();
    _startReadingTimer();
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    super.dispose();
  }

  void _startReadingTimer() {
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _readingSeconds++;
        });
      }
    });
  }

  Future<void> _translateWord(String word, String targetLanguage) async {
    setState(() {
      _selectedWord = word;
      _showTranslation = true;
    });

    try {
      await ref.read(translationProvider.notifier).translate(
        text: word,
        sourceLanguage: 'en',
        targetLanguage: targetLanguage,
        storyId: widget.storyId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _translateSentence(String sentence, String targetLanguage) async {
    setState(() {
      _selectedSentence = sentence;
      _showTranslation = true;
    });

    try {
      await ref.read(translationProvider.notifier).translate(
        text: sentence,
        sourceLanguage: 'en',
        targetLanguage: targetLanguage,
        storyId: widget.storyId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeStory() async {
    try {
      await ref.read(storyActionsProvider.notifier).completeStory(
        storyId: widget.storyId,
        readingTimeSeconds: _readingSeconds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story completed! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/stories');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete story: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storyAsync = ref.watch(storyProvider(widget.storyId));
    final authState = ref.watch(authProvider);
    final translationState = ref.watch(translationProvider);
    
    return storyAsync.when(
      data: (story) => Scaffold(
        appBar: AppBar(
          title: Text(story.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/stories'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showHelpDialog(context),
            ),
          ],
        ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Story Meta Info
                _buildMetaInfo(theme, story),
                const SizedBox(height: 24),
                
                // Interactive Story Content
                _buildInteractiveContent(theme, story, authState.user?.nativeLanguage ?? 'tr'),
                const SizedBox(height: 32),
                
                // Action Buttons
                _buildActionButtons(theme, story),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Translation Popup
          if (_showTranslation)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildTranslationPopup(theme, translationState),
            ),
        ],
      ),
        ),
        loading: () => Scaffold(
          appBar: AppBar(
            title: const Text('Loading...'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/stories'),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/stories'),
            ),
          ),
          body: Center(
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
                  'Failed to load story',
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
                  onPressed: () => ref.invalidate(storyProvider(widget.storyId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildMetaInfo(ThemeData theme, StoryModel story) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                story.cefrLevelString,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
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
                  const SizedBox(width: 12),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(_readingSeconds / 60).ceil()} min',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveContent(ThemeData theme, StoryModel story, String targetLanguage) {
    // Split content into paragraphs
    final content = story.content ?? '';
    if (content.isEmpty) {
      return Center(
        child: Text('Story content not available', style: theme.textTheme.bodyMedium),
      );
    }
    
    final paragraphs = content.split('\n\n');
    final targetWords = story.targetWords ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildInteractiveParagraph(paragraph, theme, targetWords, targetLanguage),
        );
      }).toList(),
    );
  }

  Widget _buildInteractiveParagraph(String paragraph, ThemeData theme, List<String> targetWords, String targetLanguage) {
    // Split paragraph into words
    final words = paragraph.split(' ');
    
    return Wrap(
      children: words.map((word) {
        // Clean word from punctuation for matching
        final cleanWord = word
            .toLowerCase()
            .replaceAll(RegExp(r'[.,!?;:]'), '');
        
        final isTargetWord = targetWords.map((w) => w.toLowerCase()).contains(cleanWord);
        
        return GestureDetector(
          onTap: () => _handleWordTap(cleanWord, targetLanguage),
          onLongPress: () => _handleSentenceLongPress(paragraph, targetLanguage),
          child: Container(
            padding: isTargetWord
                ? const EdgeInsets.symmetric(horizontal: 2, vertical: 1)
                : null,
            decoration: isTargetWord
                ? BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3),
                  )
                : null,
            child: Text(
              '$word ',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isTargetWord
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onSurface,
                fontWeight: isTargetWord ? FontWeight.bold : FontWeight.normal,
                height: 1.8,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleWordTap(String cleanWord, String targetLanguage) {
    _translateWord(cleanWord, targetLanguage);
  }

  void _handleSentenceLongPress(String sentence, String targetLanguage) {
    _translateSentence(sentence, targetLanguage);
  }

  Widget _buildTranslationPopup(ThemeData theme, dynamic translationState) {
    return GestureDetector(
      onTap: () => setState(() => _showTranslation = false),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Translation Header
            Row(
              children: [
                Icon(
                  _selectedWord != null
                      ? Icons.translate
                      : Icons.subject,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedWord != null ? 'Word Translation' : 'Sentence Translation',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showTranslation = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Original Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedWord ?? _selectedSentence ?? '',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Translation
            if (translationState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (translationState.translation != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  translationState.translation!.translatedText,
                  style: theme.textTheme.bodyLarge,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  translationState.error ?? 'Translation not available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Close hint
            Center(
              child: Text(
                'Tap anywhere to close',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, StoryModel story) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/stories/${story.id}/quiz');
              // context.go('/quizzes/generate/${widget.storyId}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz feature coming soon!')),
              );
            },
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Take Quiz'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: story.isCompleted == true ? null : _completeStory,
            icon: Icon(
              story.isCompleted == true 
                ? Icons.check_circle 
                : Icons.check_circle_outline,
            ),
            label: Text(story.isCompleted == true ? 'Completed' : 'Complete'),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('How to Read'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              theme,
              Icons.touch_app,
              'Tap a word',
              'Get instant translation',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              theme,
              Icons.touch_app_outlined,
              'Long press',
              'Translate entire sentence',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              theme,
              Icons.highlight,
              'Highlighted words',
              'Your target vocabulary',
              theme.colorScheme.secondary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description, [
    Color? iconColor,
  ]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
