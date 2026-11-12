import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String month; // 'MM/yyyy'
  final String categoryId;
  final String categoryName;
  final double limitAmount;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.categoryId,
    required this.categoryName,
    required this.limitAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'month': month,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'limitAmount': limitAmount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return BudgetModel(
      id: docId,
      userId: map['userId'] ?? '',
      month: map['month'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      limitAmount: (map['limitAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: parseDate(map['createdAt']),
    );
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? month,
    String? categoryId,
    String? categoryName,
    double? limitAmount,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

