import '../models/meal_feedback.dart';
import 'meal_matching.dart';

class RealMealDefinition {
  final String id;
  final List<String> aliases;
  final List<String> components;
  final MealFeedback feedback;
  const RealMealDefinition({required this.id, required this.aliases, required this.components, required this.feedback});
}

const _realMeals = <RealMealDefinition>[
  RealMealDefinition(id: 'x_bacon_batata_coca', aliases: ['x bacon', 'x-bacon'], components: ['x_bacon', 'batata_frita', 'coca_cola'], feedback: MealFeedback('Lanche completo e bem denso', 'important', 'O X-bacon com batata frita e Coca-Cola reúne proteína e carboidratos, mas também concentra gordura, sódio e açúcar em uma única refeição. A combinação é bastante densa em energia.', 'Se esse tipo de lanche for frequente, escolha água ou refrigerante sem açúcar e reduza a porção de fritas.')),
  RealMealDefinition(id: 'cheeseburger_batata_coca_zero', aliases: ['cheeseburger', 'cheese burger'], components: ['cheeseburger', 'batata_frita', 'coca_cola_zero'], feedback: MealFeedback('Combo de lanchonete identificado', 'attention', 'O cheeseburger com batata frita forma um combo com carboidratos, gordura e proteína. A Coca-Cola Zero reduz o açúcar da bebida, mas não a densidade energética do lanche.', 'Para reduzir calorias, a maior diferença costuma vir das fritas e dos molhos.')),
  RealMealDefinition(id: 'hotdog_completo_refri', aliases: ['hot dog completo', 'hotdog completo', 'cachorro quente completo', 'cachorro-quente completo'], components: ['hot_dog_completo', 'refrigerante'], feedback: MealFeedback('Cachorro-quente completo', 'attention', 'O cachorro-quente completo combina pão, salsicha e acompanhamentos, normalmente com bastante sódio. Com refrigerante, a refeição ainda ganha açúcar sem acrescentar fibras relevantes.', 'Inclua verduras, legumes ou fruta no restante do dia e prefira água ou bebida sem açúcar.')),
  RealMealDefinition(id: 'pizza_calabresa_catupiry_refri', aliases: ['pizza calabresa catupiry', 'pizza de calabresa com catupiry', 'calabresa catupiry'], components: ['pizza_calabresa_catupiry', 'refrigerante'], feedback: MealFeedback('Pizza com alta densidade energética', 'important', 'Calabresa, queijo e catupiry tornam essa pizza rica em gordura e sódio. O refrigerante tradicional acrescenta açúcar.', 'Controle a quantidade de fatias e, se possível, combine com salada.')),
  RealMealDefinition(id: 'yakisoba_frango_refri', aliases: ['yakisoba de frango', 'yakisoba frango', 'yakisoba com frango'], components: ['yakisoba_frango', 'refrigerante'], feedback: MealFeedback('Yakisoba com boa variedade, mas atenção ao sódio', 'attention', 'O yakisoba de frango combina macarrão, proteína e vegetais. O principal ponto de atenção costuma ser o molho, que pode elevar bastante o sódio; o refrigerante comum ainda adiciona açúcar.', 'Priorize vegetais e, quando possível, escolha água ou bebida sem açúcar.')),
  RealMealDefinition(id: 'parmegiana_arroz_fritas', aliases: ['frango a parmegiana', 'frango à parmegiana', 'parmegiana de frango'], components: ['frango_parmegiana', 'arroz', 'batata_frita'], feedback: MealFeedback('Parmegiana de restaurante', 'important', 'O frango à parmegiana reúne proteína, queijo e molho, mas o empanado e as fritas aumentam bastante a densidade energética e de gordura.', 'Uma porção menor de fritas e uma salada ajudam a equilibrar o prato.')),
  RealMealDefinition(id: 'escondidinho_carne_seca_sal', aliases: ['escondidinho de carne seca', 'escondidinho carne seca'], components: ['escondidinho_carne_seca', 'salada'], feedback: MealFeedback('Escondidinho com acompanhamento vegetal', 'positive', 'O escondidinho de carne seca combina carboidrato e proteína, enquanto a salada acrescenta fibras e volume à refeição. A carne seca pode elevar o sódio.', 'Mantenha a salada e observe a quantidade de recheio e de sal na preparação.')),
  RealMealDefinition(id: 'baiao_carne_seca', aliases: ['baiao de dois', 'baião de dois', 'baiao de dois com carne seca'], components: ['baiao_de_dois', 'carne_seca'], feedback: MealFeedback('Baião de dois com carne seca', 'attention', 'Arroz e feijão formam uma base com proteína vegetal e carboidratos, enquanto a carne seca aumenta a proteína, mas também pode elevar o sódio e a gordura.', 'Combine com verduras ou legumes e modere acompanhamentos muito salgados.')),
  RealMealDefinition(id: 'virado_paulista', aliases: ['virado a paulista', 'virado à paulista'], components: ['virado_paulista'], feedback: MealFeedback('Virado à paulista', 'important', 'O prato reúne feijão, arroz, farinha e acompanhamentos como bisteca, linguiça, ovo e couve. É uma refeição tradicional e bastante completa, porém densa em energia, gordura e sódio.', 'Priorize a couve e ajuste a quantidade de frituras e carnes conforme sua fome.')),
  RealMealDefinition(id: 'lasanha_bolonhesa_refri', aliases: ['lasanha bolonhesa', 'lasanha de carne'], components: ['lasanha_bolonhesa', 'refrigerante'], feedback: MealFeedback('Lasanha bolonhesa de restaurante', 'important', 'A lasanha combina massa, carne, queijo e molho, concentrando carboidratos, gordura e sódio. O refrigerante comum adiciona açúcar à refeição.', 'Uma salada como acompanhamento e água ou bebida sem açúcar deixam a refeição mais equilibrada.')),
  RealMealDefinition(id: 'acai_banana_granola_condensado', aliases: ['acai banana granola leite condensado', 'açaí banana granola leite condensado'], components: ['acai', 'banana', 'granola', 'leite_condensado'], feedback: MealFeedback('Açaí com vários complementos', 'attention', 'O açaí pode ser uma boa base, mas granola e leite condensado aumentam rapidamente carboidratos e açúcares da tigela. A banana acrescenta fruta e fibras.', 'Use complementos açucarados com moderação e prefira uma base de açaí menos adoçada quando disponível.')),
];

const _componentAliases = <String, List<String>>{
  'x_bacon': ['x bacon', 'x-bacon'],
  'cheeseburger': ['cheeseburger', 'cheese burger'],
  'hot_dog_completo': ['hot dog completo', 'hotdog completo', 'cachorro quente completo', 'cachorro-quente completo'],
  'pizza_calabresa_catupiry': ['pizza calabresa catupiry', 'pizza de calabresa com catupiry', 'calabresa catupiry'],
  'yakisoba_frango': ['yakisoba de frango', 'yakisoba frango', 'yakisoba com frango'],
  'frango_parmegiana': ['frango a parmegiana', 'frango à parmegiana', 'parmegiana de frango'],
  'escondidinho_carne_seca': ['escondidinho de carne seca', 'escondidinho carne seca'],
  'baiao_de_dois': ['baiao de dois', 'baião de dois'],
  'carne_seca': ['carne seca'],
  'virado_paulista': ['virado a paulista', 'virado à paulista'],
  'lasanha_bolonhesa': ['lasanha bolonhesa', 'lasanha de carne'],
  'acai': ['acai', 'açaí'],
  'granola': ['granola'],
  'leite_condensado': ['leite condensado'],
  'batata_frita': ['batata frita', 'fritas'],
  'coca_cola_zero': ['coca cola zero', 'coca-cola zero', 'coca zero'],
  'coca_cola': ['coca cola', 'coca-cola', 'coca'],
  'refrigerante': ['refrigerante', 'refri'],
  'arroz': ['arroz'],
  'salada': ['salada'],
};

String _normalizeRealText(String input) {
  var value = normalizeMealText(input).replaceAll('_', ' ');
  const fillers = ['comi', 'comei', 'comer', 'comendo', 'hoje', 'ontem', 'agora', 'no almoco', 'no jantar', 'no lanche', 'no cafe da manha', 'de manha', 'a tarde', 'a noite', 'tomei', 'bebi'];
  for (final filler in fillers) {
    value = value.replaceAll(RegExp(r'\b' + RegExp.escape(filler) + r'\b'), ' ');
  }
  const replacements = [
    ['coca cola zero', 'coca_cola_zero'],
    ['coca cola', 'coca_cola'],
    ['coca-cola zero', 'coca_cola_zero'],
    ['coca-cola', 'coca_cola'],
    ['coca zero', 'coca_cola_zero'],
    ['x tudo completo', 'x_tudo'],
    ['x-tudo completo', 'x_tudo'],
    ['x tudo', 'x_tudo'],
    ['x-tudo', 'x_tudo'],
  ];
  for (final replacement in replacements) {
    value = value.replaceAll(replacement[0], ' ${replacement[1]} ');
  }
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

Set<String> _recognizedComponents(String input) {
  var normalized = _normalizeRealText(input);
  final found = <String>{};
  final ordered = _componentAliases.entries.toList()..sort((a, b) {
    final aLength = a.value.fold<int>(0, (max, alias) => alias.length > max ? alias.length : max);
    final bLength = b.value.fold<int>(0, (max, alias) => alias.length > max ? alias.length : max);
    return bLength.compareTo(aLength);
  });
  for (final entry in ordered) {
    for (final alias in entry.value) {
      final normalizedAlias = _normalizeRealText(alias);
      if (normalized.contains(normalizedAlias)) {
        found.add(entry.key);
        normalized = normalized.replaceAll(normalizedAlias, ' ');
        break;
      }
    }
  }
  return found;
}

MealItemAnalysis _customItem({required String name, required String type, required bool warning, required String detail, required double calories, required double protein, required double carbs, required double fat, required double fiber}) => MealItemAnalysis(name: type == 'processed' ? 'Processado' : type == 'protein' ? 'Proteína' : type == 'carb' ? 'Carboidrato' : 'Alimento', foodName: name, type: type, isWarning: warning, detail: detail, actualCalories: calories, actualProtein: protein, actualCarbs: carbs, actualFat: fat, actualFiber: fiber);

MealItemAnalysis _realComponent(String component) {
  switch (component) {
    case 'batata_frita': return analyzeFoodItem('batata frita', 1, 'porcao');
    case 'arroz': return analyzeFoodItem('arroz', 1, 'xicara');
    case 'salada': return analyzeFoodItem('salada', 1, 'porcao');
    case 'refrigerante': return _customItem(name: 'Refrigerante', type: 'processed', warning: true, detail: 'Bebida açucarada com pouco valor nutricional.', calories: 140, protein: 0, carbs: 35, fat: 0, fiber: 0);
    case 'coca_cola': return _customItem(name: 'Coca-Cola', type: 'processed', warning: true, detail: 'Refrigerante açucarado que aumenta a carga de açúcar da refeição.', calories: 84, protein: 0, carbs: 21, fat: 0, fiber: 0);
    case 'coca_cola_zero': return _customItem(name: 'Coca-Cola Zero', type: 'processed', warning: true, detail: 'Refrigerante sem açúcar; reduz a carga de açúcar, mas não substitui alimentos nutritivos.', calories: 1, protein: 0, carbs: 0, fat: 0, fiber: 0);
    case 'x_bacon': return _customItem(name: 'X-bacon', type: 'processed', warning: true, detail: 'Hambúrguer com bacon e queijo; preparação densa em energia, gordura e sódio.', calories: 650, protein: 32, carbs: 42, fat: 40, fiber: 2);
    case 'cheeseburger': return _customItem(name: 'Cheeseburger', type: 'processed', warning: true, detail: 'Hambúrguer com queijo e pão, com densidade energética relevante.', calories: 520, protein: 27, carbs: 38, fat: 29, fiber: 2);
    case 'hot_dog_completo': return _customItem(name: 'Hot dog completo', type: 'processed', warning: true, detail: 'Pão, salsicha e acompanhamentos; costuma concentrar sódio e gordura.', calories: 560, protein: 20, carbs: 58, fat: 27, fiber: 3);
    case 'pizza_calabresa_catupiry': return _customItem(name: 'Pizza de calabresa com catupiry', type: 'processed', warning: true, detail: 'Estimativa para duas fatias; combinação rica em carboidratos, gordura e sódio.', calories: 620, protein: 25, carbs: 58, fat: 33, fiber: 3);
    case 'yakisoba_frango': return _customItem(name: 'Yakisoba de frango', type: 'carb', warning: false, detail: 'Macarrão, frango e vegetais; o molho pode elevar o teor de sódio.', calories: 520, protein: 30, carbs: 62, fat: 16, fiber: 5);
    case 'frango_parmegiana': return _customItem(name: 'Frango à parmegiana', type: 'protein', warning: true, detail: 'Frango empanado com molho e queijo; preparação densa em energia e gordura.', calories: 520, protein: 35, carbs: 28, fat: 28, fiber: 2);
    case 'escondidinho_carne_seca': return _customItem(name: 'Escondidinho de carne seca', type: 'processed', warning: true, detail: 'Purê de mandioca com carne seca; combinação rica em carboidratos e pode ter bastante sódio.', calories: 480, protein: 24, carbs: 45, fat: 22, fiber: 4);
    case 'baiao_de_dois': return _customItem(name: 'Baião de dois', type: 'carb', warning: false, detail: 'Arroz e feijão formam uma combinação de carboidrato e proteína vegetal.', calories: 390, protein: 13, carbs: 62, fat: 9, fiber: 8);
    case 'carne_seca': return _customItem(name: 'Carne seca', type: 'protein', warning: true, detail: 'Fonte de proteína, mas tradicionalmente rica em sódio.', calories: 230, protein: 32, carbs: 0, fat: 11, fiber: 0);
    case 'virado_paulista': return _customItem(name: 'Virado à paulista', type: 'processed', warning: true, detail: 'Prato completo com feijão, arroz, farinha e acompanhamentos; costuma ser denso em energia, gordura e sódio.', calories: 780, protein: 32, carbs: 78, fat: 38, fiber: 10);
    case 'lasanha_bolonhesa': return _customItem(name: 'Lasanha bolonhesa', type: 'processed', warning: true, detail: 'Massa, carne, queijo e molho em uma preparação com alta densidade energética.', calories: 560, protein: 28, carbs: 48, fat: 28, fiber: 4);
    case 'acai': return _customItem(name: 'Açaí', type: 'carb', warning: false, detail: 'Base de fruta congelada; a composição varia bastante conforme o açúcar adicionado.', calories: 220, protein: 3, carbs: 42, fat: 5, fiber: 5);
    case 'banana': return analyzeFoodItem('banana', 1, 'unidade');
    case 'granola': return _customItem(name: 'Granola', type: 'carb', warning: true, detail: 'Pode concentrar carboidratos e açúcar dependendo da formulação.', calories: 130, protein: 3, carbs: 23, fat: 4, fiber: 3);
    case 'leite_condensado': return _customItem(name: 'Leite condensado', type: 'processed', warning: true, detail: 'Cobertura concentrada em açúcar e calorias.', calories: 65, protein: 1.5, carbs: 11, fat: 1.7, fiber: 0);
    default: return _customItem(name: component, type: 'unknown', warning: false, detail: 'Componente identificado.', calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0);
  }
}

MealAnalysisReport? findRealMealAnalysis(String input, num? calories) {
  final entities = _recognizedComponents(input);
  if (entities.isEmpty) return null;
  for (final meal in _realMeals) {
    if (entities.length != meal.components.length || !meal.components.every(entities.contains)) continue;
    final items = meal.components.map(_realComponent).toList();
    final total = items.fold<double>(0, (sum, item) => sum + item.calories);
    return MealAnalysisReport(overallTitle: meal.feedback.title, overallStatus: meal.feedback.status, overallBody: meal.feedback.body, improvement: meal.feedback.improvement, itemDetails: items, totalCalories: calories ?? total, protein: items.fold<double>(0, (s, i) => s + i.protein), carbs: items.fold<double>(0, (s, i) => s + i.carbs), fat: items.fold<double>(0, (s, i) => s + i.fat), fiber: items.fold<double>(0, (s, i) => s + i.fiber));
  }
  return null;
}
