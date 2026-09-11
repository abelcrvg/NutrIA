import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_feedback.dart';
import '../supabase_config.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  // Cache to store feedbacks in memory for instant access
  Map<String, MealFeedback> _cache = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final data = await supabase
          .from('meal_feedbacks')
          .select('meal_name, title, status, body, improvement');

      final List<dynamic> rows = data as List<dynamic>;

      _cache.clear();
      for (var row in rows) {
        final name = row['meal_name'].toString().toLowerCase().trim();
        _cache[name] = MealFeedback.fromMap(row);
      }

      _initialized = true;
    } catch (e) {
      print('Error initializing FeedbackService: $e');
    }
  }

  MealFeedback? getFeedbackForMeal(String mealName) {
    // The matching logic is now handled in meal_matching.dart,
    // but we provide the catalog here.
    return _cache[mealName.toLowerCase().trim()];
  }

  Map<String, MealFeedback> get allFeedbacks => _cache;
}
