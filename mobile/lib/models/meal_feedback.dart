import 'package:flutter/material.dart';

class MealItemAnalysis {
  final String name;
  final String type; // 'carb', 'protein', 'fiber', 'processed', 'unknown'
  final bool isWarning;
  final String detail;

  const MealItemAnalysis({
    required this.name,
    required this.type,
    required this.isWarning,
    required this.detail,
  });
}

class MealAnalysisReport {
  final String overallTitle;
  final String overallStatus;
  final String overallBody;
  final String improvement;
  final List<MealItemAnalysis> itemDetails;
  final num totalCalories;

  const MealAnalysisReport({
    required this.overallTitle,
    required this.overallStatus,
    required this.overallBody,
    required this.improvement,
    required this.itemDetails,
    required this.totalCalories,
  });
}

class MealFeedback {
  final String title;
  final String status;
  final String body;
  final String improvement;

  const MealFeedback(this.title, this.status, this.body, this.improvement);

  factory MealFeedback.fromMap(Map<String, dynamic> map) {
    return MealFeedback(
      map['title'] ?? 'Análise Nutricional',
      map['status'] ?? 'information',
      map['body'] ?? 'Sem descrição disponível.',
      map['improvement'] ?? 'Tente variar seus alimentos.',
    );
  }
}
