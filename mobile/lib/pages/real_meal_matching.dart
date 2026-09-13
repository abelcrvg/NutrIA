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
  RealMealDefinition(id:'x_bacon_batata_coca',aliases:['x bacon','x-bacon'],components:['x_bacon','batata_frita','coca_cola'],feedback:MealFeedback('Lanche completo e bem denso','important','O X-bacon com batata frita e Coca-Cola reúne proteína e carboidratos, mas também concentra gordura, sódio e açúcar em uma única refeição. A combinação é bastante densa em energia, principalmente pela fritura, bacon, queijo e bebida açucarada.','Se esse tipo de lanche for frequente, escolha água ou refrigerante sem açúcar e reduza a porção de fritas. Inclua vegetais ou fruta em outras refeições do dia.')),
  RealMealDefinition(id:'cheeseburger_batata_coca_zero',aliases:['cheeseburger','cheese burger'],components:['cheeseburger','batata_frita','coca_cola_zero'],feedback:MealFeedback('Combo de lanchonete identificado','attention','O cheeseburger com batata frita forma um combo com boa quantidade de carboidratos, gordura e proteína. A Coca-Cola Zero reduz o açúcar da refeição, mas não muda a densidade energética do hambúrguer e das fritas.','Para equilibrar melhor o dia, priorize vegetais e fruta ou leguminosa em outras refeições. Para reduzir calorias, a maior diferença costuma vir das fritas e dos molhos.')),
  RealMealDefinition(id:'hotdog_completo_refri',aliases:['hot dog completo','hotdog completo','cachorro quente completo','cachorro-quente completo'],components:['hot_dog_completo','refrigerante'],feedback:MealFeedback('Cachorro-quente completo','attention','O cachorro-quente completo combina pão, salsicha e vários acompanhamentos, normalmente com bastante sódio. Com refrigerante, a refeição ganha açúcar sem acrescentar fibras ou micronutrientes relevantes.','Inclua verduras, legumes ou fruta no restante do dia e prefira água ou uma bebida sem açúcar quando possível.')),
  RealMealDefinition(id:'pizza_calabresa_catupiry_refri',aliases:['pizza calabresa catupiry','pizza de calabresa com catupiry','calabresa catupiry'],components:['pizza_calabresa_catupiry','refrigerante'],feedback:MealFeedback('Pizza com alta densidade energética','important','Calabresa, queijo e catupiry tornam essa pizza uma combinação rica em gordura e sódio. O refrigerante acrescenta açúcar quando é a versão tradicional, enquanto a refeição oferece pouca fibra se não houver vegetais ou outros acompanhamentos.','Controle a quantidade de fatias e, se possível, combine com salada. Trocar o refrigerante comum por água ou uma versão sem açúcar reduz a carga de açúcar da refeição.')),
  RealMealDefinition(id:'yakisoba_frango_refri',aliases:['yakisoba de frango','yakisoba frango','yakisoba com frango'],components:['yakisoba_frango','refrigerante'],feedback:MealFeedback('Yakisoba com boa variedade, mas atenção ao sódio','attention','O yakisoba de frango combina macarrão, proteína e vegetais, o que dá mais variedade ao prato. O principal ponto de atenção costuma ser o molho, que pode elevar bastante o sódio; o refrigerante comum ainda adiciona açúcar.','Priorize uma boa quantidade de vegetais no prato e, quando possível, escolha água ou bebida sem açúcar.')),
];

String _normalizeRealText(String input) {
  var value = normalizeMealText(input).replaceAll('_',' ');
  const fillers = ['comi','comei','comer','comendo','hoje','ontem','agora','no almoco','no jantar','no lanche','no cafe da manha','de manha','a tarde','a noite','tomei','bebi'];
  for (final filler in fillers) value = value.replaceAll(RegExp('\\b${RegExp.escape(filler)}\\b'), ' ');
  const aliases = {'x tudo':'x_tudo','x-tudo':'x_tudo','x tudo completo':'x_tudo','x-tudo completo':'x_tudo','fritas':'batata_frita','batata frita':'batata_frita','coca':'coca_cola','coca cola':'coca_cola','coca-cola':'coca_cola','coca zero':'coca_cola_zero','coca cola zero':'coca_cola_zero','coca-cola zero':'coca_cola_zero'};
  for (final entry in aliases.entries) value = value.replaceAll(entry.key,' ${entry.value} ');
  value = value.replaceAll(RegExp(r'\\b(um|uma|uns|umas)\\b'),' ');
  return value.replaceAll(RegExp(r'\\s+'),' ').trim();
}

List<String> _recognizedEntities(String input) {
  final normalized = _normalizeRealText(input);
  final entities = <String>[];
  for (final meal in _realMeals) {
    if (meal.aliases.any((alias) => normalized.contains(_normalizeRealText(alias)))) entities.add(meal.id);
  }
  if (normalized.contains('x_tudo')) entities.add('x_tudo');
  if (normalized.contains('batata_frita')) entities.add('batata_frita');
  if (normalized.contains('coca_cola_zero')) entities.add('coca_cola_zero');
  if (normalized.contains('coca_cola')) entities.add('coca_cola');
  if (normalized.contains('refrigerante')) entities.add('refrigerante');
  return entities.toSet().toList();
}

MealItemAnalysis _customItem({required String name,required String type,required bool warning,required String detail,required double calories,required double protein,required double carbs,required double fat,required double fiber}) => MealItemAnalysis(name:type=='processed'?'Processado':type=='protein'?'Proteína':type=='carb'?'Carboidrato':'Alimento',foodName:name,type:type,isWarning:warning,detail:detail,actualCalories:calories,actualProtein:protein,actualCarbs:carbs,actualFat:fat,actualFiber:fiber);

MealItemAnalysis _realComponent(String component) {
  switch(component) {
    case 'batata_frita': return analyzeFoodItem('batata frita',1,'porcao');
    case 'refrigerante': return _customItem(name:'Refrigerante',type:'processed',warning:true,detail:'Bebida açucarada com pouco valor nutricional.',calories:140,protein:0,carbs:35,fat:0,fiber:0);
    case 'coca_cola': return _customItem(name:'Coca-Cola',type:'processed',warning:true,detail:'Refrigerante açucarado que aumenta a carga de açúcar da refeição.',calories:84,protein:0,carbs:21,fat:0,fiber:0);
    case 'coca_cola_zero': return _customItem(name:'Coca-Cola Zero',type:'processed',warning:true,detail:'Refrigerante sem açúcar; reduz a carga de açúcar, mas não substitui alimentos nutritivos.',calories:1,protein:0,carbs:0,fat:0,fiber:0);
    case 'x_bacon': return _customItem(name:'X-bacon',type:'processed',warning:true,detail:'Hambúrguer com bacon e queijo; preparação densa em energia, gordura e sódio.',calories:650,protein:32,carbs:42,fat:40,fiber:2);
    case 'cheeseburger': return _customItem(name:'Cheeseburger',type:'processed',warning:true,detail:'Hambúrguer com queijo e pão, com densidade energética relevante.',calories:520,protein:27,carbs:38,fat:29,fiber:2);
    case 'hot_dog_completo': return _customItem(name:'Hot dog completo',type:'processed',warning:true,detail:'Pão, salsicha e acompanhamentos; costuma concentrar sódio e gordura.',calories:560,protein:20,carbs:58,fat:27,fiber:3);
    case 'pizza_calabresa_catupiry': return _customItem(name:'Pizza de calabresa com catupiry',type:'processed',warning:true,detail:'Estimativa para duas fatias; combinação rica em carboidratos, gordura e sódio.',calories:620,protein:25,carbs:58,fat:33,fiber:3);
    case 'yakisoba_frango': return _customItem(name:'Yakisoba de frango',type:'carb',warning:false,detail:'Macarrão, frango e vegetais; o molho pode elevar o teor de sódio.',calories:520,protein:30,carbs:62,fat:16,fiber:5);
    case 'x_tudo': return _customItem(name:'X-tudo',type:'processed',warning:true,detail:'Lanche com vários recheios; geralmente concentra calorias, gordura e sódio.',calories:750,protein:36,carbs:48,fat:45,fiber:3);
    default: return _customItem(name:component,type:'unknown',warning:false,detail:'Componente identificado.',calories:0,protein:0,carbs:0,fat:0,fiber:0);
  }
}

MealAnalysisReport? findRealMealAnalysis(String input, num? calories) {
  final entities = _recognizedEntities(input);
  if (entities.isEmpty) return null;
  for (final meal in _realMeals) {
    final matched = meal.components.every(entities.contains) && meal.components.length == entities.length;
    if (!matched) continue;
    final items = meal.components.map(_realComponent).toList();
    final total = items.fold<double>(0,(sum,item)=>sum+item.calories);
    return MealAnalysisReport(overallTitle:meal.feedback.title,overallStatus:meal.feedback.status,overallBody:meal.feedback.body,improvement:meal.feedback.improvement,itemDetails:items,totalCalories:calories??total,protein:items.fold<double>(0,(s,i)=>s+i.protein),carbs:items.fold<double>(0,(s,i)=>s+i.carbs),fat:items.fold<double>(0,(s,i)=>s+i.fat),fiber:items.fold<double>(0,(s,i)=>s+i.fiber));
  }
  return null;
}
