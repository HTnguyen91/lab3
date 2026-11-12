import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/widgets/overview_card.dart';
import 'package:expense_tracker/widgets/primary_button.dart';
import 'package:expense_tracker/utils/formatters.dart';

void main() {
  group('Unit & Widget Tests for Expense Tracker', () {
    test('Currency Formatter formats numbers correctly with VNĐ suffix', () {
      expect(Formatters.formatCurrency(45000), '45.000 VNĐ');
      expect(Formatters.formatCurrency(1200000), '1.200.000 VNĐ');
      expect(
        Formatters.formatTransactionAmount(45000, isIncome: false),
        '−45.000 VNĐ',
      );
      expect(
        Formatters.formatTransactionAmount(500000, isIncome: true),
        '+500.000 VNĐ',
      );
    });

    test('Amount Parser parses input string correctly', () {
      expect(Formatters.parseAmount('45.000'), 45000.0);
      expect(Formatters.parseAmount('1.200.000 VNĐ'), 1200000.0);
      expect(Formatters.parseAmount('invalid'), 0.0);
    });

    testWidgets('OverviewCard renders prominent amount and subtitle properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverviewCard(
              title: 'Ngân sách tháng còn lại',
              amount: 1155000,
              subtitle: 'Tổng chi hôm nay',
              subtitleAmount: 45000,
            ),
          ),
        ),
      );

      expect(find.text('Ngân sách tháng còn lại'), findsOneWidget);
      expect(find.text('1.155.000 VNĐ'), findsOneWidget);
      expect(find.text('Tổng chi hôm nay'), findsOneWidget);
      expect(find.text('45.000 VNĐ'), findsOneWidget);
    });

    testWidgets('PrimaryButton displays label and responds to tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Thêm khoản chi',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Thêm khoản chi'), findsOneWidget);
      await tester.tap(find.text('Thêm khoản chi'));
      expect(tapped, isTrue);
    });
  });
}
