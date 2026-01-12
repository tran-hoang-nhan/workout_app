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

  int _getSelectedIndex() {
    switch (activeTab) {
      case 'home': return 0;
      case 'workouts': return 1;
      case 'progress': return 2;
      case 'health': return 3;
      case 'profile': return 4;
      default: return 0;
    }
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
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 4,
            activeColor: AppColors.primary,
            iconSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              color: AppColors.grey,
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Home',
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
