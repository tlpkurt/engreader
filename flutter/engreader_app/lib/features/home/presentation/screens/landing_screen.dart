import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'dart:async';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Animated Background Circles
                  ..._buildBackgroundCircles(size),
                  
                  // Main Content
                  SafeArea(
                    child: Column(
                  children: [
                    // Header
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(seconds: 2),
                                  tween: Tween(begin: 0, end: 1),
                                  builder: (context, value, child) {
                                    return Transform.rotate(
                                      angle: value * 2 * math.pi,
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Engreader',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _AnimatedButton(
                                  onPressed: () => context.go('/login'),
                                  isOutlined: true,
                                  child: const Text('Login'),
                                ),
                                const SizedBox(width: 8),
                                _AnimatedButton(
                                  onPressed: () => context.go('/register'),
                                  isPrimary: false,
                                  child: const Text('Get Started'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Hero Content
                    Expanded(
                      child: Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(seconds: 3),
                                    tween: Tween(begin: 0, end: 1),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Icon(
                                          Icons.auto_stories_rounded,
                                          size: 120,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'Master English Through\nPersonalized Stories',
                                    style: theme.textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 32 : 48,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'AI-powered reading experience tailored to your level.\nLearn vocabulary in context, track your progress, and improve naturally.',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: isSmallScreen ? 16 : 20,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 48),
                                  _PulseButton(
                                    onPressed: () => context.go('/register'),
                                    child: const Text(
                                      'Start Learning Free',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                ],
              ),
            ),
          ),

          // Features Section
          SliverToBoxAdapter(
            child: Container(
              color: theme.colorScheme.surface,
              padding: EdgeInsets.symmetric(
                vertical: 80,
                horizontal: isSmallScreen ? 24 : 64,
              ),
              child: Column(
                children: [
                  Text(
                    'Why Choose Engreader?',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),
                  
                  Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: [
                      _FeatureCard(
                        icon: Icons.psychology_rounded,
                        title: 'AI-Powered Stories',
                        description:
                            'Stories generated specifically for your English level, from A1 to C2.',
                        color: const Color(0xFF6366F1),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.translate_rounded,
                        title: 'Instant Translation',
                        description:
                            'Tap any word or select sentences for instant translation and context.',
                        color: const Color(0xFF10B981),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Track Progress',
                        description:
                            'Monitor your reading time, vocabulary growth, and level improvements.',
                        color: const Color(0xFFF59E0B),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.quiz_rounded,
                        title: 'Interactive Quizzes',
                        description:
                            'Test your understanding with quizzes after each story.',
                        color: const Color(0xFFA855F7),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.person_rounded,
                        title: 'Personalized Learning',
                        description:
                            'Content adapts to your interests and learning pace.',
                        color: const Color(0xFF14B8A6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.devices_rounded,
                        title: 'Learn Anywhere',
                        description:
                            'Access your stories on any device, anytime, anywhere.',
                        color: const Color(0xFF6366F1),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // How It Works Section - Animated Demo
          const SliverToBoxAdapter(
            child: _AnimatedHowItWorks(),
          ),

          // CTA Section
          SliverToBoxAdapter(
            child: Container(
              color: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                vertical: 80,
                horizontal: 24,
              ),
              child: Column(
                children: [
                  Text(
                    'Ready to Start Your English Journey?',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Join thousands of learners improving their English every day',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => context.go('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Get Started for Free'),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(24),
              child: Text(
                '© 2025 Engreader. All rights reserved.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundCircles(Size size) {
    return [
      Positioned(
        top: -100,
        right: -100,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 10),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * math.pi,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            );
          },
          onEnd: () {
            if (mounted) setState(() {});
          },
        ),
      ),
      Positioned(
        bottom: -150,
        left: -150,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 12),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: -value * 2 * math.pi,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            );
          },
          onEnd: () {
            if (mounted) setState(() {});
          },
        ),
      ),
    ];
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final LinearGradient gradient;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 300,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -12.0 : 0.0, 0.0)
          ..scale(_isHovered ? 1.02 : 1.0),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.5)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withOpacity(0.4)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 30 : 15,
                offset: Offset(0, _isHovered ? 12 : 6),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Gradient Icon Container with Animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isHovered ? 90 : 80,
                height: _isHovered ? 90 : 80,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: _isHovered ? 44 : 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatefulWidget {
  final String step;
  final String title;
  final String description;

  const _StepItem({
    required this.step,
    required this.title,
    required this.description,
  });

  @override
  State<_StepItem> createState() => _StepItemState();
}

class _StepItemState extends State<_StepItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isHovered ? 72 : 60,
                  height: _isHovered ? 72 : 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(
                          _isHovered ? 0.5 : 0.3 * _pulseController.value,
                        ),
                        blurRadius: _isHovered ? 20 : 10,
                        spreadRadius: _isHovered ? 4 : 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.step,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated How It Works Section
class _AnimatedHowItWorks extends StatefulWidget {
  const _AnimatedHowItWorks();

  @override
  State<_AnimatedHowItWorks> createState() => _AnimatedHowItWorksState();
}

class _AnimatedHowItWorksState extends State<_AnimatedHowItWorks>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _currentStep = 0;
  late Timer _stepTimer;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Choose Your Level',
      'description': 'Start with your current English proficiency level (A1-C2).',
      'icon': Icons.format_list_numbered,
      'color': const Color(0xFF6366F1),
    },
    {
      'title': 'Get Personalized Stories',
      'description': 'AI generates engaging stories tailored to your level and interests.',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFF10B981),
    },
    {
      'title': 'Read & Learn',
      'description': 'Read at your own pace, tap words for translation, and learn in context.',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFF59E0B),
    },
    {
      'title': 'Practice & Progress',
      'description': 'Complete quizzes, track your progress, and level up naturally.',
      'icon': Icons.trending_up,
      'color': const Color(0xFFA855F7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _startAutoProgress();
  }

  void _startAutoProgress() {
    _progressController.forward(from: 0);
    _stepTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentStep = (_currentStep + 1) % _steps.length;
        });
        _progressController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _stepTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Container(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isSmallScreen ? 24 : 64,
      ),
      child: Column(
        children: [
          // Modern Title with Gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ).createShader(bounds),
            child: Text(
              'How It Works',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 36 : 48,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '✨ Watch your learning journey unfold',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Animated Demo Container - Full Width
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? double.infinity : 1200,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentStep;
                    final isPast = index < _currentStep;
                    
                    return Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isActive ? 12 : 8,
                          height: isActive ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPast || isActive
                                ? _steps[index]['color']
                                : Colors.grey.shade300,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: _steps[index]['color']
                                          .withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        if (index < _steps.length - 1)
                          Container(
                            width: 40,
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: isPast
                                ? _steps[index]['color']
                                : Colors.grey.shade300,
                          ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 48),

                // Animated Step Content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStepContent(
                    _currentStep,
                    theme,
                  ),
                ),

                const SizedBox(height: 32),

                // Progress Bar
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                              _steps[_currentStep]['color'],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_steps.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentStep = index;
                                });
                                _progressController.forward(from: 0);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: index == _currentStep
                                      ? _steps[index]['color']
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: index == _currentStep
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step, ThemeData theme) {
    final stepData = _steps[step];
    
    return Container(
      key: ValueKey(step),
      child: Column(
        children: [
          // App Screenshot Mockup
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0, end: 1),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildAppMockup(step, theme, stepData['color']),
              );
            },
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            stepData['title'],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            stepData['description'],
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppMockup(int step, ThemeData theme, Color accentColor) {
    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 8,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildStepScreen(step, theme, accentColor),
      ),
    );
  }

  Widget _buildStepScreen(int step, ThemeData theme, Color accentColor) {
    switch (step) {
      case 0: // Choose Level
        return _buildLevelSelectionScreen(theme, accentColor);
      case 1: // Generate Story
        return _buildStoryGenerationScreen(theme, accentColor);
      case 2: // Reading Screen
        return _buildReadingScreen(theme, accentColor);
      case 3: // Progress Screen
        return _buildProgressScreen(theme, accentColor);
      default:
        return Container();
    }
  }

  Widget _buildLevelSelectionScreen(ThemeData theme, Color accentColor) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: accentColor, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Engreader',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Your Level',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Level Cards
          Expanded(
            child: ListView(
              children: [
                _buildLevelCard('A1', 'Beginner', accentColor, true),
                const SizedBox(height: 12),
                _buildLevelCard('A2', 'Elementary', accentColor.withOpacity(0.7), false),
                const SizedBox(height: 12),
                _buildLevelCard('B1', 'Intermediate', accentColor.withOpacity(0.5), false),
                const SizedBox(height: 12),
                _buildLevelCard('B2', 'Upper Intermediate', accentColor.withOpacity(0.3), false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(String level, String name, Color color, bool selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? color : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (selected)
            Icon(Icons.check_circle, color: color, size: 24),
        ],
      ),
    );
  }

  Widget _buildStoryGenerationScreen(ThemeData theme, Color accentColor) {
    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header with back button
            Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.grey.shade700, size: 20),
                const Spacer(),
                Icon(Icons.settings_outlined, color: Colors.grey.shade700, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            
            // AI Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 35),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Generating Your Story',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'AI is creating a personalized\nstory just for you...',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Loading animation
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Column(
                  children: [
                    SizedBox(
                      width: 180,
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(accentColor),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
              onEnd: () => setState(() {}),
            ),
            const SizedBox(height: 24),
            
            // Topic & Level badges
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _buildBadge('🎨 Art', accentColor),
                _buildBadge('A1 Level', accentColor),
                _buildBadge('145 words', accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReadingScreen(ThemeData theme, Color accentColor) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.grey.shade700, size: 20),
                    const Spacer(),
                    Icon(Icons.info_outline, color: Colors.grey.shade700, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'A1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'A Day at the Park',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Story Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: Colors.grey.shade800,
                      ),
                      children: [
                        const TextSpan(text: 'Sam loves '),
                        TextSpan(
                          text: 'cars',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            backgroundColor: accentColor.withOpacity(0.1),
                          ),
                        ),
                        const TextSpan(text: '. One sunny day, he goes to a car show...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Translation Popup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.translate, color: accentColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Word Translation',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'cars → arabalar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressScreen(ThemeData theme, Color accentColor) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Progress',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Icon(Icons.settings_outlined, color: Colors.grey.shade700),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats Cards
          Expanded(
            child: ListView(
              children: [
                _buildStatCard(
                  '🔥',
                  'Streak',
                  '7 days',
                  accentColor,
                  0.7,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  '📚',
                  'Stories Read',
                  '12',
                  accentColor.withOpacity(0.8),
                  0.6,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  '✨',
                  'Words Learned',
                  '145',
                  accentColor.withOpacity(0.6),
                  0.85,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  '📈',
                  'Quiz Score',
                  '85%',
                  accentColor.withOpacity(0.4),
                  0.85,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Button Widget
class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isPrimary;
  final bool isOutlined;

  const _AnimatedButton({
    required this.onPressed,
    required this.child,
    this.isPrimary = true,
    this.isOutlined = false,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isOutlined) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: TextButton(
            onPressed: widget.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: _isHovered
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white,
            ),
            child: widget.child,
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: theme.colorScheme.primary,
            elevation: _isHovered ? 8 : 2,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// Pulse Button Widget
class _PulseButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _PulseButton({
    required this.onPressed,
    required this.child,
  });

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isHovered ? 1.1 : _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: _isHovered ? 30 : 20,
                    spreadRadius: _isHovered ? 5 : 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                  elevation: 8,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
