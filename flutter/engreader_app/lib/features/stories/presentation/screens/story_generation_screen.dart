import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../story/presentation/providers/story_provider.dart';

class StoryGenerationScreen extends ConsumerStatefulWidget {
  const StoryGenerationScreen({super.key});

  @override
  ConsumerState<StoryGenerationScreen> createState() => _StoryGenerationScreenState();
}

class _StoryGenerationScreenState extends ConsumerState<StoryGenerationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _wordsController = TextEditingController();
  
  String _selectedLevel = 'A1';
  int _wordCount = 300;

  final List<String> _cefrLevels = [
    'A1', 'A2', 'B1', 'B2', 'C1', 'C2'
  ];

  final Map<String, String> _levelDescriptions = {
    'A1': 'Beginner - Basic phrases and simple sentences',
    'A2': 'Elementary - Simple texts about familiar topics',
    'B1': 'Intermediate - Clear texts on familiar subjects',
    'B2': 'Upper-Intermediate - Complex texts on abstract topics',
    'C1': 'Advanced - Complex and detailed texts',
    'C2': 'Proficient - Almost native level texts',
  };

  @override
  void dispose() {
    _topicController.dispose();
    _wordsController.dispose();
    super.dispose();
  }

  Future<void> _generateStory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final targetWords = _wordsController.text
          .split(',')
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty)
          .toList();

      if (targetWords.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter at least one target word'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await ref.read(storyGenerationProvider.notifier).generateStory(
        cefrLevel: _selectedLevel,
        topic: _topicController.text.trim(),
        targetWords: targetWords,
        wordCount: _wordCount,
      );

      if (mounted) {
        final generationState = ref.read(storyGenerationProvider);
        if (generationState.story != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Story generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/stories/${generationState.story!.id}/read');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate story: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final generationState = ref.watch(storyGenerationProvider);
    final isGenerating = generationState.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Story',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/stories'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Create Your Personalized Story',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferences and let AI generate a custom reading exercise',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              
              // CEFR Level Selection
              Text(
                'Difficulty Level',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cefrLevels.map((level) {
                  final isSelected = level == _selectedLevel;
                  return ChoiceChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLevel = level);
                      }
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                _levelDescriptions[_selectedLevel] ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              
              // Topic
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  hintText: 'e.g., Daily Routine, Shopping, Hobbies',
                  prefixIcon: Icon(Icons.topic_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a topic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Target Words
              TextFormField(
                controller: _wordsController,
                decoration: const InputDecoration(
                  labelText: 'Target Words (comma-separated)',
                  hintText: 'e.g., breakfast, morning, school, homework',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one word';
                  }
                  final words = value.split(',').where((w) => w.trim().isNotEmpty);
                  if (words.length < 3) {
                    return 'Please enter at least 3 words';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Word Count Slider
              Text(
                'Story Length: $_wordCount words',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _wordCount.toDouble(),
                min: 150,
                max: 500,
                divisions: 7,
                label: '$_wordCount words',
                onChanged: (value) {
                  setState(() => _wordCount = value.toInt());
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '150 words',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '500 words',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Generate Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isGenerating ? null : _generateStory,
                  child: isGenerating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Generating Story...',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome),
                            const SizedBox(width: 8),
                            Text(
                              'Generate Story',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Info Card
              Card(
                color: theme.colorScheme.primary.withOpacity(0.05),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Story generation takes 10-30 seconds. The AI will create a story matching your level with at least 70% of your target words.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
