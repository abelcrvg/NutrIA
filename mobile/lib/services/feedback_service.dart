import 'dart:developer' as developer;

import '../models/meal_feedback.dart';
import '../supabase_config.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final Map<String, MealFeedback> _cache = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final data = await supabase
          .from('meal_feedbacks')
          .select('meal_name, title, status, body, improvement');

      final List<dynamic> rows = data as List<dynamic>;

      _cache.clear();
      for (final row in rows) {
        final name = row['meal_name'].toString().toLowerCase().trim();
        _cache[name] = MealFeedback.fromMap(row);
      }

      _initialized = true;
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing FeedbackService',
        name: 'FeedbackService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  MealFeedback? getFeedbackForMeal(String mealName) {
    return _cache[mealName.toLowerCase().trim()];
  }

  Map<String, MealFeedback> get allFeedbacks => _cache;
}
