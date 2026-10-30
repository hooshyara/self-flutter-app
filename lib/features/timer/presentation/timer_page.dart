import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import 'widgets/countdown_tab.dart';
import 'widgets/stopwatch_tab.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timer),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'کرنومتر'),
            Tab(text: 'تایمر'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [StopwatchTab(), CountdownTab()],
      ),
    );
  }
}
