class MealItemAnalysis {
  final String name;
  final String foodName;
  final String type;
  final bool isWarning;
  final String detail;
  final num caloriesPer100g;
  final Map<String, double> unitWeights;
  final double actualCalories;
  final double actualProtein;
  final double actualCarbs;
  final double actualFat;
  final double actualFiber;

  const MealItemAnalysis({
    required this.name,
    required this.foodName,
    required this.type,
    required this.isWarning,
    required this.detail,
    this.caloriesPer100g = 0,
    this.unitWeights = const {},
    this.actualCalories = 0,
    this.actualProtein = 0,
    this.actualCarbs = 0,
    this.actualFat = 0,
    this.actualFiber = 0,
  });

  double get calories => actualCalories;
  double get protein => actualProtein;
  double get carbs => actualCarbs;
  double get fat => actualFat;
  double get fiber => actualFiber;
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
