import 'package:flutter/material.dart';

import '../../chat/presentation/chat_page.dart';
import '../../period_tracker/presentation/period_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../timer/presentation/timer_page.dart';
import '../../todo/presentation/todo_page.dart';
import 'widgets/custom_bottom_nav.dart';

class HomePage extends StatefulWidget {
  final int? initialIndex; 

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  static const List<Widget> _pages = [
    TodoPage(),
    PeriodPage(),
    ProfilePage(),
    TimerPage(),
    ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
  }

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
