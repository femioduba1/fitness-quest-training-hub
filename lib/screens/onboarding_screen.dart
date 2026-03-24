import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';

/// Onboarding Screen — shown only on first launch
/// Collects user name, fitness goal, experience level
/// and workout frequency before entering the main app
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final PreferencesService _prefs = PreferencesService.instance;

  int _currentPage = 0;

  // ── USER DATA COLLECTED ───────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  String _selectedGoal = '';
  String _selectedLevel = '';
  int _selectedFrequency = 3;

  // ── FITNESS GOALS ─────────────────────────────────────
  static const List<Map<String, dynamic>> _goals = [
    {
      'id': 'build_muscle',
      'label': 'Build Muscle',
      'icon': '💪',
      'description': 'Gain strength and size',
    },
    {
      'id': 'lose_weight',
      'label': 'Lose Weight',
      'icon': '🔥',
      'description': 'Burn fat and get lean',
    },
    {
      'id': 'get_fit',
      'label': 'Get Fit',
      'icon': '⚡',
      'description': 'Improve overall fitness',
    },
    {
      'id': 'endurance',
      'label': 'Endurance',
      'icon': '🏃',
      'description': 'Build stamina and cardio',
    },
    {
      'id': 'stay_active',
      'label': 'Stay Active',
      'icon': '🌟',
      'description': 'Maintain healthy habits',
    },
    {
      'id': 'strength',
      'label': 'Get Stronger',
      'icon': '🏋️',
      'description': 'Maximize raw strength',
    },
  ];

  // ── EXPERIENCE LEVELS ─────────────────────────────────
  static const List<Map<String, dynamic>> _levels = [
    {
      'id': 'beginner',
      'label': 'Beginner',
      'icon': '🌱',
      'description': 'Less than 6 months of training',
    },
    {
      'id': 'intermediate',
      'label': 'Intermediate',
      'icon': '📈',
      'description': '6 months to 2 years of training',
    },
    {
      'id': 'advanced',
      'label': 'Advanced',
      'icon': '🏆',
      'description': 'More than 2 years of training',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Navigates to the next onboarding page
  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Navigates to the previous onboarding page
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Validates current page before allowing next
  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _selectedGoal.isNotEmpty && _selectedLevel.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  /// Saves all onboarding data and navigates to main app
  Future<void> _completeOnboarding() async {
    await _prefs.setUserName(_nameController.text.trim());
    await _prefs.setHasOnboarded(true);

    // Save additional preferences
    await _prefs.setWeightUnit('lbs');
    await _prefs.setFitnessGoal(_selectedGoal);
    await _prefs.setExperienceLevel(_selectedLevel);
    await _prefs.setWorkoutFrequency(_selectedFrequency);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── PROGRESS DOTS ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  // Skip button
                  GestureDetector(
                    onTap: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Page indicator dots
                  Row(
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(left: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.orange
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ── PAGE VIEW ─────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage1(size),
                  _buildPage2(size),
                  _buildPage3(size),
                ],
              ),
            ),

            // ── BOTTOM NAVIGATION ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  // Back button (hidden on first page)
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _previousPage,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),

                  // Next / Get Started button
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _canProceed() ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: _canProceed() ? _nextPage : null,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.orange, AppTheme.orangeDark],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _currentPage == 2 ? 'GET STARTED 🚀' : 'CONTINUE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 1,
                              ),
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
    );
  }

  // ── PAGE 1: NAME & WELCOME ────────────────────────────
  Widget _buildPage1(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Big welcome emoji
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('👋', style: TextStyle(fontSize: 40)),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Welcome to\nFitness Quest!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Your personal fitness companion for building consistent workout habits. Let\'s get you set up.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Name input
          Text(
            'WHAT\'S YOUR NAME?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _nameController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter your name...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 18,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.orange, width: 2),
              ),
              prefixIcon: const Icon(
                Icons.person_rounded,
                color: AppTheme.orange,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (value) => setState(() {}),
          ),

          const SizedBox(height: 24),

          // Motivational quote
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"The last three or four reps is what makes the muscle grow."\n— Arnold Schwarzenegger',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE 2: GOAL & EXPERIENCE ─────────────────────────
  Widget _buildPage2(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Greeting with name
          Text(
            'Hey ${_nameController.text.trim().isEmpty ? 'there' : _nameController.text.trim()}! 🎯',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tell us about your fitness journey so we can personalize your experience.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          // Fitness goal
          Text(
            'WHAT\'S YOUR MAIN GOAL?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 12),

          // Goal grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _goals.map((goal) {
              final isSelected = _selectedGoal == goal['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.orange.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.orange
                          : Colors.white.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(goal['icon'], style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal['label'],
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.orange
                                : Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Experience level
          Text(
            'WHAT\'S YOUR EXPERIENCE LEVEL?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 12),

          Column(
            children: _levels.map((level) {
              final isSelected = _selectedLevel == level['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.orange.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.orange
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          level['icon'],
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level['label'],
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.orange
                                      : Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                level['description'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.orange,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── PAGE 3: WORKOUT FREQUENCY ─────────────────────────
  Widget _buildPage3(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Header
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('📅', style: TextStyle(fontSize: 40)),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Almost there!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'How many days per week do you want to work out? We\'ll use this to set your default quest goals.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Frequency selector
          Text(
            'DAYS PER WEEK',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 16),

          // Big number display
          Center(
            child: Column(
              children: [
                Text(
                  '$_selectedFrequency',
                  style: const TextStyle(
                    color: AppTheme.orange,
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                Text(
                  'days per week',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.orange,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: AppTheme.orange,
              overlayColor: AppTheme.orange.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              trackHeight: 6,
            ),
            child: Slider(
              value: _selectedFrequency.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              onChanged: (value) {
                setState(() => _selectedFrequency = value.toInt());
              },
            ),
          ),

          // Day labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['1', '2', '3', '4', '5', '6', '7']
                  .map(
                    (d) => Text(
                      d,
                      style: TextStyle(
                        color: int.parse(d) == _selectedFrequency
                            ? AppTheme.orange
                            : Colors.white.withOpacity(0.3),
                        fontWeight: int.parse(d) == _selectedFrequency
                            ? FontWeight.w800
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 32),

          // Frequency description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(
                  _frequencyEmoji(_selectedFrequency),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _frequencyLabel(_selectedFrequency),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _frequencyDescription(_selectedFrequency),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // What's next section
          Text(
            'WHAT\'S NEXT',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          _WhatNextItem(
            icon: '🏋️',
            text: 'Browse 60+ exercises in the library',
          ),
          _WhatNextItem(icon: '⚡', text: 'Create your first workout quest'),
          _WhatNextItem(
            icon: '📊',
            text: 'Track your progress with ML analytics',
          ),
          _WhatNextItem(
            icon: '🤖',
            text: 'Get AI-powered training recommendations',
          ),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────

  String _frequencyEmoji(int days) {
    if (days <= 2) return '😌';
    if (days <= 3) return '💪';
    if (days <= 5) return '🔥';
    return '⚡';
  }

  String _frequencyLabel(int days) {
    if (days == 1) return 'Light Schedule';
    if (days == 2) return 'Easy Going';
    if (days == 3) return 'Balanced';
    if (days == 4) return 'Dedicated';
    if (days == 5) return 'Serious Athlete';
    if (days == 6) return 'Beast Mode';
    return 'Elite Warrior 🏆';
  }

  String _frequencyDescription(int days) {
    if (days <= 2) {
      return 'Perfect for beginners or those with a busy schedule. Quality over quantity.';
    }
    if (days <= 3) {
      return 'The sweet spot for most people. Enough rest for recovery and growth.';
    }
    if (days <= 5) {
      return 'Serious commitment. Make sure to get enough sleep and eat well.';
    }
    return 'Maximum intensity. Only for advanced athletes with excellent recovery habits.';
  }
}

/// Small bullet point for the "What\'s Next" section
class _WhatNextItem extends StatelessWidget {
  final String icon;
  final String text;

  const _WhatNextItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
