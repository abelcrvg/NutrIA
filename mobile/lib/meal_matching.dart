import 'meal_feedback_catalog.dart';

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {
    'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e',
    'í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c',
  };
  replacements.forEach((from, to) => value = value.replaceAll(from, to));
  value = value.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  const aliases = {'refri':'refrigerante','refrigerante':'refrigerante','feijao':'feijao','feijão':'feijao','frango':'frango','hamburguer':'hamburguer','batata':'batata','pao':'pao'};
  return value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).map((word) => aliases[word] ?? word).join(' ');
}

MealFeedback? findMealFeedbackSmart(String input) {
  final normalized = normalizeMealText(input);
  final exact = mealFeedbacks[normalized.replaceAll(' ', ', ')];
  if (exact != null) return exact;

  MealFeedback? best;
  var bestScore = 0.0;
  for (final entry in mealFeedbacks.entries) {
    final candidate = normalizeMealText(entry.key).split(' ').toSet();
    if (candidate.isEmpty) continue;
    final words = normalized.split(' ').toSet();
    if (!candidate.every(words.contains)) continue;
    final score = candidate.length / words.length;
    if (score > bestScore) { bestScore = score; best = entry.value; }
  }
  return best;
}
