import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_field.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AddTransactionScreen extends StatefulWidget {
  final String initialType;
  final String? prefillCategory;

  const AddTransactionScreen({
    super.key,
    this.initialType = 'expense',
    this.prefillCategory,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late String _selectedType;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    // Pre-select category if specified, default to Ăn uống (cat_food)
    _selectedCategory = AppConstants.defaultCategories.firstWhere(
      (c) => c.name == (widget.prefillCategory ?? 'Ăn uống'),
      orElse: () => AppConstants.defaultCategories.first,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    final vm = context.read<TransactionViewModel>();
    final amountText = _amountController.text;

    // Validate inputs with exact Lab 2 rules
    final isValid = vm.validateTransaction(
      amountText: amountText,
      category: _selectedCategory,
    );

    if (!isValid) return;

    final parsedAmount = Formatters.parseAmount(amountText);
    final success = await vm.saveTransaction(
      amount: parsedAmount,
      type: _selectedType,
      category: _selectedCategory!,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lưu ${_selectedType == 'expense' ? 'khoản chi' : 'khoản thu'} ${Formatters.formatCurrency(parsedAmount)}.',
          ),
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final filteredCategories = AppConstants.defaultCategories
        .where((c) => _selectedType == 'income' ? c.isIncome : !c.isIncome)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm giao dịch'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            vm.clearValidationErrors();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Selector (Khoản chi / Khoản thu)
            Container(
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = 'expense';
                          _selectedCategory = AppConstants.defaultCategories
                              .firstWhere((c) => !c.isIncome);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedType == 'expense'
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedType == 'expense'
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          'Khoản chi',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.buttonAndLabel.copyWith(
                            color: _selectedType == 'expense'
                                ? AppColors.expense
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = 'income';
                          _selectedCategory = AppConstants.defaultCategories
                              .firstWhere((c) => c.isIncome);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedType == 'income'
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedType == 'income'
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          'Khoản thu',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.buttonAndLabel.copyWith(
                            color: _selectedType == 'income'
                                ? AppColors.income
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Amount Input Field (Bắt buộc, hậu tố VNĐ)
            InputField(
              label: 'Số tiền',
              hintText: 'Nhập số tiền (ví dụ: 45.000)',
              suffixText: 'VNĐ',
              controller: _amountController,
              keyboardType: TextInputType.number,
              errorText: vm.amountError,
              prefixIcon: const Icon(
                Icons.attach_money,
                color: AppColors.textSecondary,
              ),
              onChanged: (_) {
                if (vm.amountError != null) vm.clearValidationErrors();
              },
            ),
            const SizedBox(height: AppSpacing.s16),

            // Category Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh mục',
                  style: AppTextStyles.buttonAndLabel.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppSpacing.inputRadius,
                    border: Border.all(
                      color: vm.categoryError != null
                          ? AppColors.error
                          : AppColors.inputBorder,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CategoryModel>(
                      value: _selectedCategory,
                      isExpanded: true,
                      hint: const Text(
                        'Chọn một danh mục',
                        style: AppTextStyles.caption,
                      ),
                      items: filteredCategories.map((cat) {
                        return DropdownMenuItem<CategoryModel>(
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
                        if (vm.categoryError != null) {
                          vm.clearValidationErrors();
                        }
                      },
                    ),
                  ),
                ),
                if (vm.categoryError != null) ...[
                  const SizedBox(height: 4),
                  Text(vm.categoryError!, style: AppTextStyles.errorCaption),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s16),

            // Date Picker Field
            InputField(
              label: 'Ngày giao dịch',
              hintText: Formatters.formatDate(_selectedDate),
              readOnly: true,
              onTap: _pickDate,
              prefixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
              ),
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Note Field (Tùy chọn)
            InputField(
              label: 'Ghi chú (tùy chọn)',
              hintText: 'Ví dụ: Ăn trưa cơm sườn, Cà phê cùng bạn...',
              controller: _noteController,
              prefixIcon: const Icon(
                Icons.edit_note,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s32),

            // Save Button
            PrimaryButton(
              label: 'Lưu giao dịch',
              isLoading: vm.isSaving,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
