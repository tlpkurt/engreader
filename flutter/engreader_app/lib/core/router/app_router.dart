import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/stories/presentation/screens/story_list_screen.dart';
import '../../features/stories/presentation/screens/story_reading_screen.dart';
import '../../features/stories/presentation/screens/story_generation_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_result_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Home Route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const LandingScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Story Routes
      GoRoute(
        path: '/stories',
        name: 'stories',
        builder: (context, state) => const StoryListScreen(),
      ),
      GoRoute(
        path: '/stories/generate',
        name: 'story-generate',
        builder: (context, state) => const StoryGenerationScreen(),
      ),
      GoRoute(
        path: '/stories/:id/read',
        name: 'story-reading',
        builder: (context, state) {
          final storyId = state.pathParameters['id']!;
          return StoryReadingScreen(storyId: storyId);
        },
      ),
      
      // Quiz Routes
      GoRoute(
        path: '/stories/:storyId/quiz',
        name: 'quiz',
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          return QuizScreen(storyId: storyId);
        },
      ),
      GoRoute(
        path: '/quiz/result',
        name: 'quiz-result',
        builder: (context, state) {
          final resultData = state.extra as Map<String, dynamic>?;
          return QuizResultScreen(resultData: resultData);
        },
      ),
      
      // Progress Route
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
    ],
  );
});
