import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../screens/home_screen.dart';
import '../screens/habit_list_screen.dart';
import '../screens/focus_hub_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController(index: 0);

  final List<Widget> _screens = [
    const HomeScreen(),
    const HabitListScreen(),
    const FocusHubScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        showLabel: true,
        notchColor: AppColors.primary,
        removeMargins: false,
        kBottomRadius: 28.0,
        kIconSize: 24.0,
        shadowElevation: 5,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.textGrey,
            ),
            activeItem: Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
            ),
            itemLabel: 'Today',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.list_alt_rounded,
              color: AppColors.textGrey,
            ),
            activeItem: Icon(
              Icons.list_alt_rounded,
              color: Colors.white,
            ),
            itemLabel: 'Habits',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.center_focus_strong_rounded,
              color: AppColors.textGrey,
            ),
            activeItem: Icon(
              Icons.center_focus_strong_rounded,
              color: Colors.white,
            ),
            itemLabel: 'Focus',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.bar_chart_rounded,
              color: AppColors.textGrey,
            ),
            activeItem: Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
            ),
            itemLabel: 'Stats',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.person_outline_rounded,
              color: AppColors.textGrey,
            ),
            activeItem: Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
            ),
            itemLabel: 'Profile',
          ),
        ],
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        },
      ),
    );
  }
}
