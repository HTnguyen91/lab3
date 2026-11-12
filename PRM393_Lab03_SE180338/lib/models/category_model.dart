import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final bool isIncome;
  final int colorValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.isIncome,
    required this.colorValue,
  });

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'isIncome': isIncome,
      'colorValue': colorValue,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      name: map['name'] ?? '',
      iconCodePoint: map['iconCodePoint'] ?? Icons.category.codePoint,
      isIncome: map['isIncome'] ?? false,
      colorValue: map['colorValue'] ?? 0xFF64748B,
    );
  }
}
