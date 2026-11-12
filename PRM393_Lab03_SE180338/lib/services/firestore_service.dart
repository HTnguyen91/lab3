import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/report_model.dart';
import '../models/notification_item.dart';
import '../utils/formatters.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _userCollection(String uid, String sub) {
    return _firestore.collection('users').doc(uid).collection(sub);
  }

  // ================= TRANSACTIONS =================

  /// Stream transactions sorted by date descending (Real-time listener)
  Stream<List<TransactionModel>> streamTransactions(String uid) {
    return _userCollection(
      uid,
      'transactions',
    ).orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Create transaction
  Future<String> addTransaction(String uid, TransactionModel tx) async {
    final docRef = await _userCollection(uid, 'transactions').add(tx.toMap());
    return docRef.id;
  }

  /// Update transaction
  Future<void> updateTransaction(String uid, TransactionModel tx) async {
    await _userCollection(uid, 'transactions').doc(tx.id).update(tx.toMap());
  }

  /// Delete transaction
  Future<void> deleteTransaction(String uid, String txId) async {
    await _userCollection(uid, 'transactions').doc(txId).delete();
  }

  // ================= BUDGETS =================

  /// Stream budgets for user
  Stream<List<BudgetModel>> streamBudgets(String uid) {
    return _userCollection(uid, 'budgets').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BudgetModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Create or update budget for a category in a month
  Future<void> setBudget(String uid, BudgetModel budget) async {
    final col = _userCollection(uid, 'budgets');
    if (budget.id.isNotEmpty) {
      await col.doc(budget.id).set(budget.toMap());
    } else {
      // Find if one exists with same month & categoryId
      final query = await col
          .where('month', isEqualTo: budget.month)
          .where('categoryId', isEqualTo: budget.categoryId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await col.doc(query.docs.first.id).update({
          'limitAmount': budget.limitAmount,
          'categoryName': budget.categoryName,
        });
      } else {
        await col.add(budget.toMap());
      }
    }
  }

  /// Delete budget
  Future<void> deleteBudget(String uid, String budgetId) async {
    await _userCollection(uid, 'budgets').doc(budgetId).delete();
  }

  // ================= REPORTS =================

  /// Stream reports
  Stream<List<ReportModel>> streamReports(String uid) {
    return _userCollection(
      uid,
      'reports',
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Save report metadata
  Future<void> saveReport(String uid, ReportModel report) async {
    await _userCollection(uid, 'reports').add(report.toMap());
  }

  // ================= NOTIFICATIONS =================

  /// Stream notifications
  Stream<List<NotificationItem>> streamNotifications(String uid) {
    return _userCollection(
      uid,
      'notifications',
    ).orderBy('receivedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationItem.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Save notification
  Future<void> saveNotification(String uid, NotificationItem item) async {
    await _userCollection(uid, 'notifications').doc(item.id).set(item.toMap());
  }

  // ================= SEED TEST DATA =================

  /// Seed initial Lab 2 test data for demo
  Future<void> seedLab2Data(String uid) async {
    final now = DateTime.now();
    final currentMonth = Formatters.formatMonth(now);

    // Seed initial budget for Ăn uống: 3.000.000 VNĐ
    await setBudget(
      uid,
      BudgetModel(
        id: '',
        userId: uid,
        month: currentMonth,
        categoryId: 'cat_food',
        categoryName: 'Ăn uống',
        limitAmount: 3000000.0,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    );

    // Seed initial budget for Đi lại: 1.000.000 VNĐ
    await setBudget(
      uid,
      BudgetModel(
        id: '',
        userId: uid,
        month: currentMonth,
        categoryId: 'cat_transport',
        categoryName: 'Đi lại',
        limitAmount: 1000000.0,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    );

    // Seed initial transactions
    final initialTx = [
      TransactionModel(
        id: '',
        userId: uid,
        amount: 5000000.0,
        type: 'income',
        categoryId: 'cat_salary',
        categoryName: 'Tiền lương & Thưởng',
        date: DateTime(now.year, now.month, 1),
        note: 'Lương thực tập tháng $currentMonth',
        createdAt: now.subtract(const Duration(days: 11)),
      ),
      TransactionModel(
        id: '',
        userId: uid,
        amount: 405000.0,
        type: 'expense',
        categoryId: 'cat_food',
        categoryName: 'Ăn uống',
        date: DateTime(now.year, now.month, 2),
        note: 'Siêu thị thực phẩm đầu tháng',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      TransactionModel(
        id: '',
        userId: uid,
        amount: 250000.0,
        type: 'expense',
        categoryId: 'cat_transport',
        categoryName: 'Đi lại',
        date: DateTime(now.year, now.month, 5),
        note: 'Đổ xăng xe máy',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      TransactionModel(
        id: '',
        userId: uid,
        amount: 350000.0,
        type: 'expense',
        categoryId: 'cat_bills',
        categoryName: 'Hóa đơn & Tiện ích',
        date: DateTime(now.year, now.month, 8),
        note: 'Tiền internet',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    for (var tx in initialTx) {
      await addTransaction(uid, tx);
    }
  }
}
