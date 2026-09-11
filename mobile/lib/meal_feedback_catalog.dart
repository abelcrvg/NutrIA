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
};

MealFeedback? findMealFeedback(String input) {
  final normalized = input.toLowerCase().trim().replaceAll(RegExp(r'\\s+'), ' ');
  return mealFeedbacks[normalized];
}

IconData feedbackIcon(String status) {
  switch (status) {
    case 'positive': return Icons.check_circle_outline;
    case 'attention': return Icons.warning_amber_rounded;
    case 'important': return Icons.error_outline;
    default: return Icons.info_outline;
  }
}
