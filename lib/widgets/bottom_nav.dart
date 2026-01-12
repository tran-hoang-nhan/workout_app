import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../constants/app_constants.dart';

class BottomNav extends StatelessWidget {
  final String activeTab;
  final void Function(String) setActiveTab;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.setActiveTab,
  });

<<<<<<< HEAD
  int _getSelectedIndex() {
    switch (activeTab) {
      case 'home': return 0;
      case 'workouts': return 1;
      case 'progress': return 2;
      case 'health': return 3;
      case 'profile': return 4;
      default: return 0;
    }
=======
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<Offset> _offsetAnimation;

  final List<TabItem> tabs = const [
    TabItem(id: 'home', label: 'Trang chủ', icon: Icons.home),
    TabItem(id: 'workouts', label: 'Bài tập', icon: Icons.fitness_center),
    TabItem(id: 'progress', label: 'Tiến độ', icon: Icons.trending_up),
    TabItem(id: 'health', label: 'Sức khỏe', icon: Icons.local_activity),
    TabItem(id: 'profile', label: 'Cá nhân', icon: Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    ));

    _entryController.forward();
>>>>>>> a3765084fb1a30e57af7763144d9d118c306f086
  }

  String _getTabId(int index) {
    switch (index) {
      case 0: return 'home';
      case 1: return 'workouts';
      case 2: return 'progress';
      case 3: return 'health';
      case 4: return 'profile';
      default: return 'home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
<<<<<<< HEAD
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black.withValues(alpha: .08),
              offset: const Offset(0, 4),
            )
=======
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 20, top: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tabs.map((tab) {
                final isActive = widget.activeTab == tab.id;
                return Expanded(
                  child: _TabButton(
                    tab: tab,
                    isActive: isActive,
                    onTap: () => widget.setActiveTab(tab.id),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class TabItem {
  final String id;
  final String label;
  final IconData icon;

  const TabItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _TabButton extends StatefulWidget {
  final TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _yOffsetAnimation;
  late Animation<double> _labelScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final spring = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(spring);
    _yOffsetAnimation = Tween<double>(begin: 0, end: -2).animate(spring);
    _labelScaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(spring);

    if (widget.isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant _TabButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.isActive
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: widget.isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _yOffsetAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Icon(
                      widget.tab.icon,
                      size: 16,
                      color: widget.isActive ? Colors.white : AppColors.grey,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _labelScaleAnimation.value,
                  child: Text(
                    widget.tab.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      color: widget.isActive ? Colors.white : AppColors.grey,
                    ),
                  ),
                );
              },
            ),
>>>>>>> a3765084fb1a30e57af7763144d9d118c306f086
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 4,
            activeColor: AppColors.primary,
            iconSize: 22,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              color: AppColors.grey,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Trang chủ',
                ),
                GButton(
                  icon: Icons.fitness_center_rounded,
                  text: 'Bài tập',
                ),
                GButton(
                  icon: Icons.trending_up_rounded,
                  text: 'Tiến độ',
                ),
                GButton(
                  icon: Icons.local_activity_rounded,
                  text: 'Sức khỏe',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Cá nhân',
                ),
              ],
              selectedIndex: _getSelectedIndex(),
              onTabChange: (index) {
                setActiveTab(_getTabId(index));
              },
            ),
          ),
        ),
    );
  }
}

