import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_field.dart';
import '../widgets/design_widgets.dart';
import '../theme/app_colors.dart';
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
      (c) => widget.initialType == 'income'
          ? c.isIncome
          : c.name == (widget.prefillCategory ?? 'Ăn uống'),
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFECFDF5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đã lưu ${_selectedType == 'expense' ? 'khoản chi' : 'khoản thu'} ${Formatters.formatCurrency(parsedAmount)}.',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      _allowPop = true;
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(
        () => _saveError =
            'Không thể lưu giao dịch. Kiểm tra kết nối và thử lại.',
      );
    }
  }

  bool _allowPop = false;
  String? _saveError;
  bool get _dirty =>
      _amountController.text.isNotEmpty || _noteController.text.isNotEmpty;
  Future<void> _close() async {
    if (context.read<TransactionViewModel>().isSaving) return;
    if (_dirty && !await confirmDiscard(context)) return;
    if (!mounted) return;
    context.read<TransactionViewModel>().clearValidationErrors();
    setState(() => _allowPop = true);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final categories = AppConstants.defaultCategories
        .where((c) => _selectedType == 'income' ? c.isIncome : !c.isIncome)
        .toList();
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thêm Giao Dịch'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _close,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    for (final type in ['expense', 'income'])
                      Expanded(
                        child: Material(
                          color: _selectedType == type
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: vm.isSaving
                                ? null
                                : () => setState(() {
                                    _selectedType = type;
                                    _selectedCategory = AppConstants
                                        .defaultCategories
                                        .firstWhere(
                                          (c) =>
                                              c.isIncome == (type == 'income'),
                                        );
                                  }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                type == 'expense' ? 'Khoản chi' : 'Khoản thu',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.buttonAndLabel.copyWith(
                                  color: _selectedType == type
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DesignCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Text(
                      _selectedType == 'expense'
                          ? 'SỐ TIỀN CHI TIÊU'
                          : 'SỐ TIỀN THU NHẬP',
                      style: AppTextStyles.caption,
                    ),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.prominentAmount,
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixText: 'VNĐ',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorText: vm.amountError,
                      ),
                      onChanged: (_) {
                        if (vm.amountError != null) vm.clearValidationErrors();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DesignCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Danh mục',
                            style: AppTextStyles.groupTitle,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            'Đã chọn: ${_selectedCategory?.name ?? "Chưa chọn"}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final cat = categories[i];
                          final selected = _selectedCategory == cat;
                          return Semantics(
                            selected: selected,
                            button: true,
                            label: cat.name,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: vm.isSaving
                                  ? null
                                  : () =>
                                        setState(() => _selectedCategory = cat),
                              child: Container(
                                width: 64,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryTint
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    CategoryIcon(
                                      name: cat.name,
                                      selected: selected,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      cat.name,
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (vm.categoryError != null)
                      Text(
                        vm.categoryError!,
                        style: AppTextStyles.errorCaption,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DesignCard(
                child: Column(
                  children: [
                    InputField(
                      label: 'Ngày giao dịch',
                      hintText: Formatters.formatDate(_selectedDate),
                      readOnly: true,
                      onTap: _pickDate,
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      label: 'Ghi chú',
                      hintText: 'Ví dụ: Cơm trưa sinh viên',
                      controller: _noteController,
                      prefixIcon: const Icon(Icons.edit_note, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_saveError!, style: AppTextStyles.errorCaption),
                ),
              PrimaryButton(
                label: 'Lưu giao dịch',
                icon: Icons.check_circle_outline,
                isLoading: vm.isSaving,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
