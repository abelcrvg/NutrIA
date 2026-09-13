import '../models/meal_feedback.dart';
import 'meal_feedback_extra.dart';
import 'meal_feedback_batch_06.dart';
import 'meal_feedback_batch_07.dart';

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e','í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c'};
  replacements.forEach((from,to)=>value=value.replaceAll(from,to));
  value = value.replaceAll('batata frita', 'batata_frita');
  value = value.replaceAll('arroz integral', 'arroz_integral');
  value = value.replaceAll('batata doce', 'batata-doce');
  const aliases={'refri':'refrigerante','burguer':'hamburguer','paes':'pao','ovos':'ovo','feijoes':'feijao'};
  const ignored={'e','com','de','da','do','das','dos'};
  value=value.replaceAll(RegExp(r'[^a-z0-9\s_-]+'),' ');
  return value.split(RegExp(r'\s+')).where((w)=>w.isNotEmpty&&!ignored.contains(w)).map((w)=>aliases[w]??w).join(' ');
}
String _canonical(String input){final words=normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toList()..sort();return words.join('|');}
final Map<String,MealFeedback> _feedbackByCanonical={for(final e in {...mealFeedbackExtras,...mealFeedbackBatch06,...mealFeedbackBatch07}.entries)_canonical(e.key):e.value};