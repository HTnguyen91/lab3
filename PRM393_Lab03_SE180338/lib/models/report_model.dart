import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final String month;
  final double totalExpense;
  final double totalIncome;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.month,
    required this.totalExpense,
    required this.totalIncome,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'month': month,
      'totalExpense': totalExpense,
      'totalIncome': totalIncome,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    return ReportModel(
      id: docId,
      userId: map['userId'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      month: map['month'] ?? '',
      totalExpense: (map['totalExpense'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (map['totalIncome'] as num?)?.toDouble() ?? 0.0,
      createdAt: parseDate(map['createdAt']),
    );
  }
}

