import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../quiz/presentation/providers/quiz_provider.dart';

class QuizResultScreen extends ConsumerWidget {
  final String quizId;
  
  const QuizResultScreen({
    super.key,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final submissionState = ref.watch(quizSubmissionProvider);

    if (submissionState.result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
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
              const Text('No results available'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/stories'),
                child: const Text('Back to Stories'),
              ),
            ],
          ),
        ),
      );
    }

    final result = submissionState.result!;
    final score = result.score;
    final totalQuestions = result.totalQuestions;
    final percentage = (score / totalQuestions * 100).round();
    final passed = percentage >= 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/stories'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.emoji_events : Icons.sentiment_neutral,
                    size: 64,
                    color: passed
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed ? 'Great Job!' : 'Keep Practicing!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You scored',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$score',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' / $totalQuestions',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: passed
                          ? theme.colorScheme.secondary.withOpacity(0.1)
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$percentage%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: passed
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Review Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Review Answers',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Questions Review
          ...List.generate(result.questions.length, (index) {
            final question = result.questions[index];
            return _buildQuestionReview(
              theme,
              question,
              index + 1,
            );
          }),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Clear submission state and go back to stories
                    ref.read(quizSubmissionProvider.notifier).clearResult();
                    context.go('/stories');
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Stories'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Clear states and retry quiz
                    ref.read(quizSubmissionProvider.notifier).clearResult();
                    ref.read(quizGenerationProvider.notifier).clearQuiz();
                    context.pop();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Quiz'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuestionReview(
    ThemeData theme,
    dynamic question,
    int questionNumber,
  ) {
    final userAnswer = question.userAnswerIndex;
    final correctAnswer = question.correctAnswerIndex;
    final isCorrect = userAnswer == correctAnswer;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Number & Status
            Row(
              children: [
                Text(
                  'Question $questionNumber',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCorrect ? 'Correct' : 'Incorrect',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Question Text
            Text(
              question.question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Options
            ...List.generate(question.options.length, (index) {
              final isUserAnswer = userAnswer == index;
              final isCorrectAnswer = correctAnswer == index;
              final showAsCorrect = isCorrectAnswer;
              final showAsIncorrect = isUserAnswer && !isCorrect;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: showAsCorrect
                      ? Colors.green.withOpacity(0.1)
                      : showAsIncorrect
                          ? Colors.red.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: showAsCorrect
                        ? Colors.green
                        : showAsIncorrect
                            ? Colors.red
                            : theme.colorScheme.outline.withOpacity(0.3),
                    width: showAsCorrect || showAsIncorrect ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      showAsCorrect
                          ? Icons.check_circle
                          : showAsIncorrect
                              ? Icons.cancel
                              : Icons.circle_outlined,
                      size: 20,
                      color: showAsCorrect
                          ? Colors.green
                          : showAsIncorrect
                              ? Colors.red
                              : theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: showAsCorrect || showAsIncorrect
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            // Explanation (if available)
            if (question.explanation != null && question.explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explanation',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            question.explanation!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
