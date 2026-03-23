import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeToggle extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onToggled; // called AFTER animation completes

  const ThemeToggle({
    super.key,
    required this.isDark,
    required this.onToggled,
  });

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Set initial position
    if (!_isDark) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (_isDark) {
      // Switching to light
      await _controller.forward();
    } else {
      // Switching to dark
      await _controller.reverse();
    }
    // Only update theme AFTER animation completes
    setState(() => _isDark = !_isDark);
    widget.onToggled(_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 72,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.lerp(
                const Color(0xFF1C1C1C),
                const Color(0xFFE0E0E0),
                _slideAnimation.value,
              ),
              border: Border.all(
                color: Color.lerp(
                  AppTheme.orange.withOpacity(0.4),
                  AppTheme.orange.withOpacity(0.6),
                  _slideAnimation.value,
                )!,
              ),
            ),
            child: Stack(
              children: [
                // Sun icon (right side)
                Positioned(
                  right: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: _slideAnimation.value,
                      child: const Icon(
                        Icons.wb_sunny_rounded,
                        size: 16,
                        color: AppTheme.orange,
                      ),
                    ),
                  ),
                ),

                // Moon icon (left side)
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: 1 - _slideAnimation.value,
                      child: const Icon(
                        Icons.nightlight_round,
                        size: 16,
                        color: AppTheme.orange,
                      ),
                    ),
                  ),
                ),

                // Sliding thumb
                Positioned(
                  left: 2 + (_slideAnimation.value * 36),
                  top: 2,
                  child: RotationTransition(
                    turns: _isDark
                        ? Tween(begin: 0.0, end: 0.5).animate(_controller)
                        : Tween(begin: 0.5, end: 1.0).animate(_controller),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.orange,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.orange.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isDark
                            ? Icons.nightlight_round
                            : Icons.wb_sunny_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}