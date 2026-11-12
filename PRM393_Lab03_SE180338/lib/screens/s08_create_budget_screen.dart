import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/budget_viewmodel.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/input_field.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class CreateBudgetScreen extends StatefulWidget {
  final String? initialCategoryName;
  final double? initialAmount;

  const CreateBudgetScreen({
    super.key,
    this.initialCategoryName,
    this.initialAmount,
  });

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  late String _selectedMonth;
  CategoryModel? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final budgetVm = context.read<BudgetViewModel>();
    _selectedMonth = budgetVm.selectedMonth;

    if (widget.initialCategoryName != null) {
      _selectedCategory = AppConstants.defaultCategories.firstWhere(
        (c) => c.name == widget.initialCategoryName,
        orElse: () => AppConstants.defaultCategories.first,
      );
    } else {
      _selectedCategory = AppConstants.defaultCategories.first;
    }

    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amountController.text = widget.initialAmount!.round().toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _errorText = 'Nhập số tiền hạn mức.';
      });
      return;
    }

    final limit = Formatters.parseAmount(amountText);
    if (limit <= 0) {
      setState(() {
        _errorText = 'Hạn mức phải lớn hơn 0 VNĐ.';
      });
      return;
    }

    if (_selectedCategory == null) {
      setState(() {
        _errorText = 'Chọn một danh mục.';
      });
      return;
    }

    final success = await context.read<BudgetViewModel>().saveBudget(
      month: _selectedMonth,
      category: _selectedCategory!,
      limitAmount: limit,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lưu ngân sách ${_selectedCategory!.name}: ${Formatters.formatCurrency(limit)}.',
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _handleCancel() {
    // UF-03: Hủy bỏ dữ liệu đang nhập và trở về S07
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final budgetVm = context.watch<BudgetViewModel>();
    final expenseCategories = AppConstants.defaultCategories
        .where((c) => !c.isIncome)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo ngân sách danh mục'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleCancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Picker Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tháng áp dụng', style: AppTextStyles.buttonAndLabel),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.inputRadius,
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      isExpanded: true,
                      items: _getAvailableMonths().map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m, style: AppTextStyles.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (newMonth) {
                        if (newMonth != null) {
                          setState(() {
                            _selectedMonth = newMonth;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            // Category Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Danh mục chi tiêu', style: AppTextStyles.buttonAndLabel),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.inputRadius,
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CategoryModel>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: expenseCategories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.icon, size: 20, color: cat.color),
                              const SizedBox(width: AppSpacing.s12),
                              Text(cat.name, style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (cat) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            // Limit Amount Input Field
            InputField(
              label: 'Hạn mức ngân sách',
              hintText: 'Nhập số tiền (ví dụ: 3.000.000)',
              suffixText: 'VNĐ',
              controller: _amountController,
              keyboardType: TextInputType.number,
              errorText: _errorText,
              prefixIcon: const Icon(
                Icons.payments_outlined,
                color: AppColors.textSecondary,
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.s32),

            // Action Buttons (Lưu & Hủy)
            PrimaryButton(
              label: 'Lưu ngân sách',
              isLoading: budgetVm.isSaving,
              onPressed: _handleSave,
            ),
            const SizedBox(height: AppSpacing.s12),
            SecondaryButton(label: 'Hủy', onPressed: _handleCancel),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableMonths() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      return Formatters.formatMonth(date);
    });
  }
}
