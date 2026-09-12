import 'package:flutter/material.dart';

class MealLog {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  final num? calories;
  final List<dynamic>? ingredients;

  MealLog({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.calories,
    this.ingredients,
  });

  factory MealLog.fromMap(Map<String, dynamic> r) {
    return MealLog(
      id: r['id'].toString(),
      name: (r['meal_name'] as String?)?.trim().isNotEmpty == true
          ? r['meal_name'] as String
          : 'Refeição',
      type: (r['meal_type'] as String?)?.trim().isNotEmpty == true
          ? r['meal_type'] as String
          : 'Outra',
      createdAt: DateTime.tryParse(r['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      calories: r['calories'] as num?,
      ingredients: r['ingredients'] as List<dynamic>?,
    );
  }
}
