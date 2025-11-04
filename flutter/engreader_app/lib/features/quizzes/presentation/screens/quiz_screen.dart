import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../quiz/presentation/providers/quiz_provider.dart';
import '../../../quiz/data/models/quiz_model.dart';
import '../../../story/data/models/story_model.dart';
import '../../../story/presentation/providers/story_provider.dart';
import '../../../../core/network/api_client.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String storyId;
  
  const QuizScreen({
    super.key,
    required this.storyId,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  // Map<questionNumber, answerIndex> to match backend expectations
  final Map<int, int> _selectedAnswers = {};
  bool _isLoading = true;
  String? _errorMessage;
  QuizData? _quizData; // Store QuizData directly from story

  @override
  void initState() {
    super.initState();
    // Load story and extract quiz from it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizFromStory();
    });
  }

  Future<void> _loadQuizFromStory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch story with quiz included - storyProvider is a FutureProvider.family
      final story = await ref.read(storyProvider(widget.storyId).future);
      
      if (story.quiz == null || story.quiz!.questions.isEmpty) {
        setState(() {
          _errorMessage = 'Quiz not available for this story';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _quizData = story.quiz!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load quiz: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int questionNumber, int answerIndex) {
    setState(() {
      _selectedAnswers[questionNumber] = answerIndex;
    });
  }

  Future<void> _submitQuiz(QuizData quiz) async {
    // Check if all questions are answered
    if (_selectedAnswers.length < quiz.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Convert answer index (0,1,2,3) to letter (A,B,C,D)
      // Backend expects: Dictionary<int, string> where int = questionNumber, string = "A"/"B"/"C"/"D"
      // JSON requires string keys, so we convert to Map<String, String>
      final answersMap = <String, String>{};
      _selectedAnswers.forEach((questionNumber, answerIndex) {
        final answerLetter = ['A', 'B', 'C', 'D'][answerIndex];
        answersMap[questionNumber.toString()] = answerLetter;
      });

      // Now we need to update submitQuiz to accept this format
      // For now, let's use the direct API call
      // Note: apiClient already adds /api/v1 prefix, so we just need the endpoint
      final response = await ref.read(apiClientProvider).post(
        '/quizzes/submit',
        data: {
          'quizId': quiz.id,
          'answers': answersMap,
          'timeSpentSeconds': 0, // TODO: Track actual time
        },
      );

      if (mounted) {
        // Navigate to results screen with data
        final resultData = response.data['data'];
        context.go('/quiz/result', extra: resultData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit quiz: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submissionState = ref.watch(quizSubmissionProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Loading Quiz...',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Loading quiz questions...',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quiz Error',
            style: TextStyle(fontWeight: FontWeight.w600),
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
                'Failed to load quiz',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/stories'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Stories'),
              ),
            ],
          ),
        ),
      );
    }

    final quiz = _quizData;
    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quiz',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(
          child: Text('No quiz available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Quiz?'),
                content: const Text('Your progress will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/stories');
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: _selectedAnswers.length / quiz.questions.length,
            backgroundColor: theme.colorScheme.surfaceVariant,
          ),
          
          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quiz.questions.length,
              itemBuilder: (context, index) {
                final question = quiz.questions[index];
                return _buildQuestionCard(
                  theme,
                  question,
                  quiz.questions.length,
                );
              },
            ),
          ),
          
          // Submit Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: submissionState.isLoading
                      ? null
                      : () => _submitQuiz(quiz),
                  child: submissionState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit Quiz (${_selectedAnswers.length}/${quiz.questions.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    ThemeData theme,
    QuizQuestionData question,
    int totalQuestions,
  ) {
    final selectedAnswer = _selectedAnswers[question.questionNumber];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Number
            Text(
              'Question ${question.questionNumber} of $totalQuestions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Question Text
            Text(
              question.question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Options
            ...List.generate(4, (index) {
              final isSelected = selectedAnswer == index;
              final option = [question.optionA, question.optionB, question.optionC, question.optionD][index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _selectAnswer(question.questionNumber, index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
