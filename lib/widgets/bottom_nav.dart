import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class BottomNav extends StatelessWidget {
  final String activeTab;
  final void Function(String) setActiveTab;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.setActiveTab,
  });

  final List<_TabItem> tabs = const [
    _TabItem(id: 'home', label: 'Trang chủ', icon: Icons.home),
    _TabItem(id: 'workouts', label: 'Bài tập', icon: Icons.fitness_center),
    _TabItem(id: 'health', label: 'Sức khỏe', icon: Icons.local_activity),
    _TabItem(id: 'profile', label: 'Cá nhân', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
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
              final isActive = activeTab == tab.id;
              return Expanded(
                child: _TabButton(
                  tab: tab,
                  isActive: isActive,
                  onTap: () => setActiveTab(tab.id),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String id;
  final String label;
  final IconData icon;

  const _TabItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _TabButton extends StatefulWidget {
  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    Key? key,
    required this.tab,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

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
                      size: 20,
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
                      fontSize: 10,
                      fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      color: widget.isActive ? Colors.white : AppColors.grey,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

