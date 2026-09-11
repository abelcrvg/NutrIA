import 'package:flutter/material.dart';

class MealFeedback {
  final String title;
  final String status;
  final String body;
  final String improvement;
  const MealFeedback(this.title, this.status, this.body, this.improvement);
}

const mealFeedbacks = <String, MealFeedback>{
  'arroz, ovo e salada': MealFeedback('Boa combinação', 'positive', 'O arroz fornece carboidratos, o ovo acrescenta proteína e a salada contribui com vegetais e fibras.', 'Varie os vegetais e ajuste as porções ao restante da refeição.'),
  'tapioca, frango e salada': MealFeedback('Boa combinação', 'positive', 'O frango acrescenta proteína à tapioca, enquanto a salada aumenta a variedade de vegetais. A tapioca continua sendo predominantemente fonte de carboidratos.', 'Inclua uma porção adequada de vegetais e varie as fontes de carboidrato.'),
  'hambúrguer e salada': MealFeedback('Pode ficar mais completa', 'information', 'O hambúrguer fornece proteína, mas sua preparação pode aumentar gordura e sódio. A salada acrescenta vegetais e fibras.', 'Prefira preparações menos gordurosas quando possível e mantenha a salada variada.'),
  'pizza de queijo e refrigerante': MealFeedback('Atenção à combinação', 'attention', 'A pizza de queijo fornece carboidratos e gordura, enquanto o refrigerante açucarado acrescenta açúcar. A combinação tende a ter pouca fibra e variedade de vegetais.', 'Troque o refrigerante por água ou uma opção sem açúcar e acrescente vegetais quando possível.'),
  'pão francês, ovo e café com açúcar': MealFeedback('Atenção ao conjunto', 'attention', 'O pão fornece carboidratos, o ovo acrescenta proteína e o café adoçado contribui com açúcar adicionado. A refeição pode ter pouca fibra.', 'Inclua uma fruta ou outra fonte de fibras e modere o açúcar adicionado.'),
  'arroz, feijão, ovo e salada': MealFeedback('Refeição bem distribuída', 'positive', 'O arroz fornece carboidratos, o feijão acrescenta fibras e nutrientes, o ovo fornece proteína e a salada amplia a variedade de vegetais.', 'Varie as verduras e legumes e ajuste as porções de acordo com sua rotina alimentar.'),
  'macarrão, carne e salada': MealFeedback('Boa combinação', 'positive', 'O macarrão é uma fonte de carboidratos, a carne contribui com proteína e a salada adiciona vegetais e fibras.', 'Priorize preparações com menos óleo e varie os vegetais ao longo da semana.'),
  'hambúrguer e batata frita': MealFeedback('Atenção ao conjunto', 'attention', 'O hambúrguer fornece proteína, mas pode concentrar gordura e sódio. A batata frita aumenta a densidade energética por causa da fritura.', 'Reduza a frequência ou a porção da fritura e acrescente vegetais à refeição.'),
  'açaí com banana': MealFeedback('Pode ser uma boa opção', 'information', 'A banana contribui com carboidratos, fibras e micronutrientes, enquanto o açaí fornece energia e pode fazer parte de uma refeição ou lanche. O preparo e os acompanhamentos mudam bastante o perfil final.', 'Observe a quantidade de açúcar e coberturas adicionadas e considere combinar com uma fonte de proteína quando fizer sentido.'),
  'iogurte, banana e aveia': MealFeedback('Boa combinação', 'positive', 'O iogurte fornece proteína, a banana contribui com carboidratos e fibras, e a aveia acrescenta fibras e ajuda a tornar a refeição mais completa.', 'Prefira iogurte natural quando possível e varie as frutas e sementes ao longo da semana.'),
};

MealFeedback? findMealFeedback(String input) {
  final normalized = normalizeMealText(input);
  MealFeedback? best;
  var bestScore = 0.0;
  final words = normalized.split(' ').where((word) => word.isNotEmpty).toSet();
  if (words.isEmpty) return null;
  for (final entry in mealFeedbacks.entries) {
    final candidate = normalizeMealText(entry.key).split(' ').where((word) => word.isNotEmpty).toSet();
    if (candidate.isEmpty || !candidate.every(words.contains)) continue;
    final score = candidate.length / words.length;
    if (score > bestScore) {
      bestScore = score;
      best = entry.value;
    }
  }
  return best;
}

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e','í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c'};
  replacements.forEach((from, to) => value = value.replaceAll(from, to));
  value = value.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  const aliases = {'refri':'refrigerante','burguer':'hamburguer','pao':'pao','feijao':'feijao'};
  return value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).map((word) => aliases[word] ?? word).join(' ');
}

IconData feedbackIcon(String status) {
  switch (status) {
    case 'positive': return Icons.check_circle_outline;
    case 'attention': return Icons.warning_amber_rounded;
    case 'important': return Icons.error_outline;
    default: return Icons.info_outline;
  }
}
