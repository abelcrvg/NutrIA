import 'package:flutter/material.dart';

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
