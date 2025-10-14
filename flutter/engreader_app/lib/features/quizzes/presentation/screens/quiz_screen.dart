import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../quiz/presentation/providers/quiz_provider.dart';
import '../../../quiz/data/models/quiz_model.dart';

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
  final Map<String, int> _selectedAnswers = {};
  bool _isGenerating = false;
  String? _generatedQuizId;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    setState(() => _isGenerating = true);
    
    try {
      await ref.read(quizGenerationProvider.notifier).generateQuiz(widget.storyId);
      
      final generationState = ref.read(quizGenerationProvider);
      if (generationState.quiz != null) {
        setState(() {
          _generatedQuizId = generationState.quiz!.id;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate quiz: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectAnswer(String questionId, int answerIndex) {
    setState(() {
      _selectedAnswers[questionId] = answerIndex;
    });
  }

  Future<void> _submitQuiz(QuizModel quiz) async {
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
      final answers = _selectedAnswers.entries
          .map((entry) => AnswerModel(
                questionId: entry.key,
                answerIndex: entry.value,
              ))
          .toList();

      await ref.read(quizSubmissionProvider.notifier).submitQuiz(
            quizId: quiz.id,
            answers: answers,
          );

      if (mounted) {
        final submissionState = ref.read(quizSubmissionProvider);
        if (submissionState.result != null) {
          context.go('/quiz/result/${quiz.id}');
        }
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
    final generationState = ref.watch(quizGenerationProvider);
    final submissionState = ref.watch(quizSubmissionProvider);

    if (_isGenerating || generationState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Generating Quiz...'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Creating quiz questions...',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (generationState.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Error'),
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
                'Failed to generate quiz',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  generationState.error!,
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

    final quiz = generationState.quiz;
    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(
          child: Text('No quiz available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
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
                  index + 1,
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
                child: ElevatedButton(
                  onPressed: submissionState.isLoading
                      ? null
                      : () => _submitQuiz(quiz),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
    QuizQuestionModel question,
    int questionNumber,
    int totalQuestions,
  ) {
    final selectedAnswer = _selectedAnswers[question.id];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Number
            Text(
              'Question $questionNumber of $totalQuestions',
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
            ...List.generate(question.options.length, (index) {
              final isSelected = selectedAnswer == index;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _selectAnswer(question.id, index),
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
                            question.options[index],
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
