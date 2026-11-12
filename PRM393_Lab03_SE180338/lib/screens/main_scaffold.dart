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
      bottomNavigationBar: Container(
        height: 64,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, 'Trang chủ', Icons.home_rounded, Icons.home_outlined),
            _buildNavItem(1, 'Lịch sử', Icons.history_rounded, Icons.history_outlined),
            _buildNavItem(2, 'Thống kê', Icons.bar_chart_rounded, Icons.bar_chart_outlined),
            _buildNavItem(
              3,
              'Ngân sách',
              Icons.account_balance_wallet_rounded,
              Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData activeIcon,
    IconData inactiveIcon,
  ) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _navigateToIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryTint : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
