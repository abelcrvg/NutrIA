import 'meal_feedback_catalog.dart';
import 'meal_feedback_extra.dart';

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e','í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c'};
  replacements.forEach((from,to)=>value=value.replaceAll(from,to));
  value=value.replaceAll(RegExp(r'[^a-z0-9]+'),' ');
  const aliases={'refri':'refrigerante','burguer':'hamburguer','pao':'pao'};
  return value.split(RegExp(r'\s+')).where((w)=>w.isNotEmpty).map((w)=>aliases[w]??w).join(' ');
}
String _canonical(String input){final words=normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toList()..sort();return words.join('|');}
final Map<String,MealFeedback> _canonicalFeedbacks=(){final r=<String,MealFeedback>{};for(final e in {...mealFeedbacks,...mealFeedbackExtras}.entries){r[_canonical(e.key)]=e.value;}return r;}();
MealFeedback? findMealFeedbackSmart(String input){final exact=_canonicalFeedbacks[_canonical(input)];if(exact!=null)return exact;final words=normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toSet();MealFeedback? best;var bestScore=0.0;for(final e in _canonicalFeedbacks.entries){final candidate=e.key.split('|').toSet();if(candidate.isEmpty||!candidate.every(words.contains))continue;final score=candidate.length/words.length;if(score>bestScore){bestScore=score;best=e.value;}}return best;}
