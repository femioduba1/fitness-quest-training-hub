import 'package:flutter/material.dart';

class SlideMenu extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavigate;

  const SlideMenu({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  State<SlideMenu> createState() => SlideMenuState();
}

class SlideMenuState extends State<SlideMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openMenu() {
    setState(() => _isOpen = true);
    _controller.forward();
  }

  void closeMenu() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void toggleMenu() {
    if (_isOpen) {
      closeMenu();
    } else {
      openMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── MAIN CONTENT ────────────────────────────
        widget.child,

        // ── OVERLAY MENU ────────────────────────────
        if (_isOpen)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _MenuOverlay(
                  currentIndex: widget.currentIndex,
                  onNavigate: (index) {
                    closeMenu();
                    Future.delayed(
                      const Duration(milliseconds: 200),
                      () => widget.onNavigate(index),
                    );
                  },
                  onClose: closeMenu,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;
  final VoidCallback onClose;

  const _MenuOverlay({
    required this.currentIndex,
    required this.onNavigate,
    required this.onClose,
  });

  static const List<_MenuItem> _items = [
    _MenuItem(
      index: 0,
      label: 'Home',
      sublabel: 'Dashboard & active quests',
      icon: Icons.home_rounded,
    ),
    _MenuItem(
      index: 1,
      label: 'Library',
      sublabel: 'Browse & log exercises',
      icon: Icons.fitness_center_rounded,
    ),
    _MenuItem(
      index: 2,
      label: 'Create Quest',
      sublabel: 'Build a new challenge',
      icon: Icons.add_circle_rounded,
    ),
    _MenuItem(
      index: 3,
      label: 'Progress',
      sublabel: 'Stats, history & records',
      icon: Icons.bar_chart_rounded,
    ),
    _MenuItem(
      index: 4,
      label: 'AI Trainer',
      sublabel: 'Smart recommendations',
      icon: Icons.psychology_rounded,
    ),
    _MenuItem(
      index: 5,
      label: 'Settings',
      sublabel: 'Theme, profile & preferences',
      icon: Icons.settings_rounded,
    ),
    _MenuItem(
      index: 6,
      label: 'Progress Photos',
      sublabel: 'Track your transformation',
      icon: Icons.photo_library_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      // Material fixes yellow underlines on text
      color: const Color(0xFFFF6000),
      child: GestureDetector(
        onTap: onClose,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: GestureDetector(
              // Prevent taps on menu from closing
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FITNESS',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                height: 1,
                              ),
                            ),
                            Text(
                              'QUEST',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        // Close button
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Divider(
                      color: Colors.black.withOpacity(0.2),
                      thickness: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── MENU ITEMS ─────────────────────
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final isActive = item.index == currentIndex;
                        return _AnimatedMenuItem(
                          item: item,
                          isActive: isActive,
                          delay: Duration(milliseconds: 50 * index),
                          onTap: () => onNavigate(item.index),
                        );
                      },
                    ),
                  ),

                  // ── FOOTER ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                    child: Text(
                      'FITNESS QUEST • CSC 4360',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedMenuItem extends StatefulWidget {
  final _MenuItem item;
  final bool isActive;
  final Duration delay;
  final VoidCallback onTap;

  const _AnimatedMenuItem({
    required this.item,
    required this.isActive,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? Colors.black.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isActive
                    ? Colors.black.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.item.icon, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 16),

                // Label + sublabel
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.label.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.item.sublabel,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Active indicator dot
                if (widget.isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final int index;
  final String label;
  final String sublabel;
  final IconData icon;

  const _MenuItem({
    required this.index,
    required this.label,
    required this.sublabel,
    required this.icon,
  });
}
