import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_colors.dart';
import 's01_home_screen.dart';
import 's03_history_screen.dart';
import 's05_statistics_screen.dart';
import 's07_budget_screen.dart';
import 's10_profile_screen.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    final screens = [
      HomeScreen(onOpenHistory: () => _navigateToIndex(1)),
      const HistoryScreen(),
      const StatisticsScreen(),
      const BudgetScreen(),
    ];

    final titles = [
      'Trang chủ',
      'Lịch sử giao dịch',
      'Thống kê chi tiêu',
      'Ngân sách danh mục',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          IconButton(
            tooltip: 'Hồ sơ cá nhân & Cài đặt',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryTint,
              backgroundImage: authVm.photoUrl != null
                  ? NetworkImage(authVm.photoUrl!)
                  : null,
              child: authVm.photoUrl == null
                  ? const Icon(Icons.person, size: 18, color: AppColors.primary)
                  : null,
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Ngân sách',
          ),
        ],
      ),
    );
  }
}
