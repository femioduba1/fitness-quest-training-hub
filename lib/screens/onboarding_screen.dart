import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/bmi_service.dart';
import '../database/crud/body_measurement_crud.dart';
import '../theme/app_theme.dart';
import '../main.dart';

/// Onboarding Screen — shown only on first launch
/// Collects name, goal, experience level, height, weight and frequency
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _pageController =
      PageController();
  final PreferencesService _prefs =
      PreferencesService.instance;

  int _currentPage = 0;

  // ── USER DATA ─────────────────────────────────────────
  final TextEditingController _nameController =
      TextEditingController();
  String _selectedGoal = '';
  String _selectedLevel = '';
  int _selectedFrequency = 3;
  double _heightCm = 170;
  double _weightKg = 70;

  // Calculated BMI shown live on page 3
  double get _currentBMI =>
      BMIService.instance.calculateBMI(_weightKg, _heightCm);

  static const List<Map<String, dynamic>> _goals = [
    {'id': 'build_muscle', 'label': 'Build Muscle', 'icon': '💪', 'description': 'Gain strength and size'},
    {'id': 'lose_weight', 'label': 'Lose Weight', 'icon': '🔥', 'description': 'Burn fat and get lean'},
    {'id': 'get_fit', 'label': 'Get Fit', 'icon': '⚡', 'description': 'Improve overall fitness'},
    {'id': 'endurance', 'label': 'Endurance', 'icon': '🏃', 'description': 'Build stamina and cardio'},
    {'id': 'stay_active', 'label': 'Stay Active', 'icon': '🌟', 'description': 'Maintain healthy habits'},
    {'id': 'strength', 'label': 'Get Stronger', 'icon': '🏋️', 'description': 'Maximize raw strength'},
  ];

  static const List<Map<String, dynamic>> _levels = [
    {'id': 'beginner', 'label': 'Beginner', 'icon': '🌱', 'description': 'Less than 6 months of training'},
    {'id': 'intermediate', 'label': 'Intermediate', 'icon': '📈', 'description': '6 months to 2 years of training'},
    {'id': 'advanced', 'label': 'Advanced', 'icon': '🏆', 'description': 'More than 2 years of training'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _selectedGoal.isNotEmpty &&
            _selectedLevel.isNotEmpty;
      case 2:
        return _heightCm > 0 && _weightKg > 0;
      default:
        return false;
    }
  }

  Future<void> _completeOnboarding() async {
    await _prefs.setUserName(
        _nameController.text.trim());
    await _prefs.setHasOnboarded(true);
    await _prefs.setWeightUnit('lbs');
    await _prefs.setFitnessGoal(_selectedGoal);
    await _prefs.setExperienceLevel(_selectedLevel);
    await _prefs.setWorkoutFrequency(_selectedFrequency);
    await _prefs.setHeightCm(_heightCm);
    await _prefs.setInitialWeightKg(_weightKg);

    // Log initial measurement to start tracking
    final bmi = BMIService.instance
        .calculateBMI(_weightKg, _heightCm);
    await BodyMeasurementCrud().insertMeasurement({
      'weight_kg': _weightKg,
      'height_cm': _heightCm,
      'bmi': bmi,
      'notes': 'Initial measurement from onboarding',
    });

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation,
                  secondaryAnimation) =>
              const MainNavigation(),
          transitionsBuilder: (context, animation,
              secondaryAnimation, child) {
            return FadeTransition(
                opacity: animation, child: child);
          },
          transitionDuration:
              const Duration(milliseconds: 600),
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
              padding: const EdgeInsets.fromLTRB(
                  24, 20, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color:
                            Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children:
                        List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 300),
                        margin:
                            const EdgeInsets.only(left: 6),
                        width: _currentPage == index
                            ? 24
                            : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.orange
                              : Colors.white
                                  .withOpacity(0.3),
                          borderRadius:
                              BorderRadius.circular(4),
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
                physics:
                    const NeverScrollableScrollPhysics(),
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

            // ── BOTTOM NAV ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  24, 0, 24, 32),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _previousPage,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (_currentPage > 0)
                    const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _canProceed() ? 1.0 : 0.5,
                      duration: const Duration(
                          milliseconds: 200),
                      child: GestureDetector(
                        onTap: _canProceed()
                            ? _nextPage
                            : null,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.orange,
                                AppTheme.orangeDark,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _currentPage == 2
                                  ? 'GET STARTED 🚀'
                                  : 'CONTINUE',
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('👋',
                  style: TextStyle(fontSize: 40)),
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
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your personal fitness companion for college students. Let\'s get you set up in under a minute.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
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
                borderSide: const BorderSide(
                    color: AppTheme.orange, width: 2),
              ),
              prefixIcon: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.orange),
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('💬',
                    style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"The last three or four reps is what makes the muscle grow." — Arnold Schwarzenegger',
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
            'Tell us about your fitness journey so we can personalize everything.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _goals.map((goal) {
              final isSelected =
                  _selectedGoal == goal['id'];
              return GestureDetector(
                onTap: () => setState(
                    () => _selectedGoal = goal['id']),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.orange.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.orange
                          : Colors.white.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(goal['icon'],
                          style:
                              const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal['label'],
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.orange
                                : Colors.white
                                    .withOpacity(0.8),
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
              final isSelected =
                  _selectedLevel == level['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(
                      () => _selectedLevel = level['id']),
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.orange.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.orange
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(level['icon'],
                            style: const TextStyle(
                                fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                level['label'],
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.orange
                                      : Colors.white,
                                  fontWeight:
                                      FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                level['description'],
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.5),
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

  // ── PAGE 3: HEIGHT, WEIGHT & FREQUENCY ───────────────
  Widget _buildPage3(Size size) {
    final bmi = _currentBMI;
    final bmiCategory =
        BMIService.instance.getBMICategory(bmi);
    final bmiColor = BMIService.instance.getBMIColor(bmi);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('📏',
                  style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Body Measurements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll use your height and weight to calculate your BMI and track your progress toward your goal.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // ── HEIGHT SLIDER ──────────────────────────
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HEIGHT',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${_heightCm.toStringAsFixed(0)} cm  (${_cmToFeetInches(_heightCm)})',
                style: const TextStyle(
                  color: AppTheme.orange,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.orange,
              inactiveTrackColor:
                  Colors.white.withOpacity(0.1),
              thumbColor: AppTheme.orange,
              overlayColor:
                  AppTheme.orange.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 14),
              trackHeight: 6,
            ),
            child: Slider(
              value: _heightCm,
              min: 140,
              max: 220,
              divisions: 80,
              onChanged: (value) =>
                  setState(() => _heightCm = value),
            ),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text('140 cm',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11)),
              Text('220 cm',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11)),
            ],
          ),

          const SizedBox(height: 24),

          // ── WEIGHT SLIDER ──────────────────────────
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEIGHT',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${_weightKg.toStringAsFixed(1)} kg  (${(_weightKg * 2.205).toStringAsFixed(1)} lbs)',
                style: const TextStyle(
                  color: AppTheme.orange,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.orange,
              inactiveTrackColor:
                  Colors.white.withOpacity(0.1),
              thumbColor: AppTheme.orange,
              overlayColor:
                  AppTheme.orange.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 14),
              trackHeight: 6,
            ),
            child: Slider(
              value: _weightKg,
              min: 40,
              max: 150,
              divisions: 110,
              onChanged: (value) =>
                  setState(() => _weightKg = value),
            ),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text('40 kg',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11)),
              Text('150 kg',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11)),
            ],
          ),

          const SizedBox(height: 24),

          // ── LIVE BMI CARD ──────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bmiColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: bmiColor.withOpacity(0.4),
                  width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: TextStyle(
                        color: bmiColor,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BMI',
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          bmiCategory,
                          style: TextStyle(
                            color: bmiColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // BMI scale bar
                _buildBMIScaleBar(bmi),
                const SizedBox(height: 12),
                Text(
                  _getBMIMessage(bmi, _selectedGoal),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── WORKOUT FREQUENCY ──────────────────────
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAYS PER WEEK',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '$_selectedFrequency days',
                style: const TextStyle(
                  color: AppTheme.orange,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3, 4, 5, 6, 7].map((day) {
              final isSelected = _selectedFrequency == day;
              return GestureDetector(
                onTap: () => setState(
                    () => _selectedFrequency = day),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.orange
                        : Colors.white.withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.orange
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // What's next
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
          _WhatNextItem(icon: '🏋️', text: 'Browse 60+ exercises across 6 muscle groups'),
          _WhatNextItem(icon: '⚡', text: 'Get AI-personalized quest suggestions'),
          _WhatNextItem(icon: '📊', text: 'Track your BMI trend toward your goal'),
          _WhatNextItem(icon: '📅', text: 'Weekly Sunday reminders to log your weight'),
        ],
      ),
    );
  }

  // ── BMI SCALE BAR ─────────────────────────────────────
  Widget _buildBMIScaleBar(double bmi) {
    const minBMI = 15.0;
    const maxBMI = 40.0;
    final position =
        ((bmi - minBMI) / (maxBMI - minBMI)).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          children: [
            // Gradient bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2196F3), // Underweight - blue
                    Color(0xFF4CAF50), // Normal - green
                    Color(0xFFFFC107), // Overweight - yellow
                    Color(0xFFF44336), // Obese - red
                  ],
                  stops: [0.0, 0.28, 0.55, 1.0],
                ),
              ),
            ),
            // Indicator line
            Positioned(
              left: position *
                  (MediaQuery.of(context).size.width -
                      48 -
                      8),
              top: -4,
              child: Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text('Under',
                style: TextStyle(
                    color: const Color(0xFF2196F3),
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
            Text('Normal',
                style: TextStyle(
                    color: const Color(0xFF4CAF50),
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
            Text('Over',
                style: TextStyle(
                    color: const Color(0xFFFFC107),
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
            Text('Obese',
                style: TextStyle(
                    color: const Color(0xFFF44336),
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  String _cmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }

  String _getBMIMessage(double bmi, String goal) {
    final category =
        BMIService.instance.getBMICategory(bmi);
    if (goal == 'build_muscle' && bmi < 22) {
      return 'For muscle building, we\'ll help you gain healthy mass to reach your target range.';
    }
    if (goal == 'lose_weight' && bmi > 25) {
      return 'We\'ll create a plan to bring your BMI into the healthy range through consistent training.';
    }
    if (category == 'Normal') {
      return 'Great starting point! We\'ll help you maintain and optimize your fitness from here.';
    }
    return 'We\'ll track your BMI weekly and adjust your program to help you reach your target range.';
  }
}

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