import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/budget_viewmodel.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/input_field.dart';
import '../widgets/design_widgets.dart';
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

    final vm = context.read<BudgetViewModel>();
    if (widget.initialCategoryName == null &&
        vm.allBudgets.any(
          (b) =>
              b.month == _selectedMonth &&
              b.categoryId == _selectedCategory!.id,
        )) {
      setState(
        () => _errorText = 'Danh mục này đã có ngân sách trong tháng. Hãy chỉnh sửa ngân sách đã có.',
      );
      return;
    }
    final success = await vm.saveBudget(
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
      _allowPop = true;
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(
        () => _errorText =
            'Không thể lưu ngân sách. Kiểm tra kết nối và thử lại.',
      );
    }
  }

  bool _allowPop = false;
  Future<void> _handleCancel() async {
    if (context.read<BudgetViewModel>().isSaving) return;
    final initial = widget.initialAmount?.round().toString() ?? '';
    if ((_amountController.text != initial ||
            _selectedCategory?.name !=
                (widget.initialCategoryName ??
                    AppConstants.defaultCategories.first.name) ||
            _selectedMonth != context.read<BudgetViewModel>().selectedMonth) &&
        !await confirmDiscard(context)) {
      return;
    }
    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final budgetVm = context.watch<BudgetViewModel>();
    final expenseCategories = AppConstants.defaultCategories
        .where((c) => !c.isIncome)
        .toList();

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleCancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tạo Ngân Sách'),
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
              const DesignCard(
                color: AppColors.primaryTint,
                child: Row(
                  children: [
                    Icon(Icons.savings_outlined, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thiết lập mục tiêu kiểm soát',
                            style: AppTextStyles.buttonAndLabel,
                          ),
                          Text(
                            'Đặt hạn mức chi tiêu thông minh giúp bạn không bị hụt ví vào cuối tháng.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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

              // Category selection matches the chip group in the Figma form.
              DesignCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danh mục chi tiêu',
                      style: AppTextStyles.buttonAndLabel,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CategoryIcon(
                          name: _selectedCategory!.name,
                          selected: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedCategory!.name,
                                style: AppTextStyles.bodyMedium,
                              ),
                              const Text(
                                'Chi tiêu thiết yếu hàng ngày',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gợi ý danh mục phổ biến:',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: expenseCategories
                          .map(
                            (cat) => ChoiceChip(
                              label: Text(
                                cat.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: _selectedCategory == cat,
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: _selectedCategory == cat
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              onSelected: budgetVm.isSaving
                                  ? null
                                  : (_) =>
                                        setState(() => _selectedCategory = cat),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [2000000, 3000000, 4000000, 5000000]
                    .map(
                      (amount) => ActionChip(
                        label: Text(
                          Formatters.formatCurrency(amount.toDouble()),
                          style: const TextStyle(fontSize: 11),
                        ),
                        onPressed: budgetVm.isSaving
                            ? null
                            : () => setState(() {
                                _amountController.text = amount.toString();
                                _errorText = null;
                              }),
                      ),
                    )
                    .toList(),
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
