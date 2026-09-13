class MealItemAnalysis {
  final String name;
  final String foodName;
  final String type;
  final bool isWarning;
  final String detail;
  final num caloriesPer100g;
  final Map<String, double> unitWeights;
  final double actualCalories;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;

  const MealItemAnalysis({
    required this.name,
    required this.foodName,
    required this.type,
    required this.isWarning,
    required this.detail,
    this.caloriesPer100g = 0,
    this.unitWeights = const {},
    this.actualCalories = 0,
    this.proteinPer100g = 0,
    this.carbsPer100g = 0,
    this.fatPer100g = 0,
    this.fiberPer100g = 0,
  });

  double get calories => actualCalories;
  double _macro(double per100g) {
    if (caloriesPer100g == 0) return 0;
    final unit = unitWeights.values.isEmpty ? 1.0 : 1.0;
    return per100g * unit / 100;
  }

  double get protein => _macro(proteinPer100g);
  double get carbs => _macro(carbsPer100g);
  double get fat => _macro(fatPer100g);
  double get fiber => _macro(fiberPer100g);
}

class MealAnalysisReport {
  final String overallTitle;
  final String overallStatus;
  final String overallBody;
  final String improvement;
  final List<MealItemAnalysis> itemDetails;
  final num totalCalories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const MealAnalysisReport({
    required this.overallTitle,
    required this.overallStatus,
    required this.overallBody,
    required this.improvement,
    required this.itemDetails,
    required this.totalCalories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
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
