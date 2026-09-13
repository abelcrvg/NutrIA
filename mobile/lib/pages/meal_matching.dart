import '../models/meal_feedback.dart';
import 'meal_feedback_extra.dart';
import 'meal_feedback_batch_06.dart';
import 'meal_feedback_batch_07.dart';
import 'meal_feedback_batch_08.dart';

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e','í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c'};
  replacements.forEach((from, to) => value = value.replaceAll(from, to));
  value = value.replaceAll('batata frita', 'batata_frita').replaceAll('arroz integral', 'arroz_integral').replaceAll('batata doce', 'batata-doce');
  const aliases = {'refri':'refrigerante','burguer':'hamburguer','paes':'pao','ovos':'ovo','feijoes':'feijao'};
  const ignored = {'e','com','de','da','do','das','dos'};
  value = value.replaceAll(RegExp(r'[^a-z0-9\s_-]+'), ' ');
  return value.split(RegExp(r'\s+')).where((w) => w.isNotEmpty && !ignored.contains(w)).map((w) => aliases[w] ?? w).join(' ');
}

String _canonical(String input) {
  final words = normalizeMealText(input).split(' ').where((w) => w.isNotEmpty).toList()..sort();
  return words.join('|');
}

final Map<String, MealFeedback> _feedbackByCanonical = {
  for (final entry in {...mealFeedbackExtras, ...mealFeedbackBatch06, ...mealFeedbackBatch07, ...mealFeedbackBatch08}.entries)
    _canonical(entry.key): entry.value,
};

const Map<String, Map<String, dynamic>> foodDatabase = {
  'arroz': {'cal_100g':130,'protein':2.5,'carbs':28.2,'fat':0.3,'fiber':1.6,'weights':{'colher':25.0,'xicara':150.0,'grama':1.0}},
  'arroz_integral': {'cal_100g':123,'protein':2.6,'carbs':25.6,'fat':1.0,'fiber':2.7,'weights':{'colher':25.0,'xicara':150.0,'grama':1.0}},
  'feijao': {'cal_100g':91,'protein':4.8,'carbs':14.0,'fat':0.5,'fiber':8.5,'weights':{'colher':30.0,'concha':120.0,'grama':1.0}},
  'frango': {'cal_100g':165,'protein':31.0,'carbs':0.0,'fat':3.6,'fiber':0.0,'weights':{'pedaco':100.0,'unidade':100.0,'grama':1.0}},
  'carne': {'cal_100g':250,'protein':26.0,'carbs':0.0,'fat':17.0,'fiber':0.0,'weights':{'bife':120.0,'pedaco':100.0,'grama':1.0}},
  'peixe': {'cal_100g':130,'protein':26.0,'carbs':0.0,'fat':2.5,'fiber':0.0,'weights':{'file':120.0,'pedaco':100.0,'grama':1.0}},
  'ovo': {'cal_100g':155,'protein':13.0,'carbs':1.1,'fat':10.6,'fiber':0.0,'weights':{'unidade':50.0,'ovo':50.0,'grama':1.0}},
  'batata': {'cal_100g':87,'protein':1.9,'carbs':20.1,'fat':0.1,'fiber':1.8,'weights':{'unidade':150.0,'porcao':100.0,'grama':1.0}},
  'batata_frita': {'cal_100g':312,'protein':3.4,'carbs':41.0,'fat':14.7,'fiber':3.8,'weights':{'porcao':100.0,'grama':1.0}},
  'batata-doce': {'cal_100g':86,'protein':1.6,'carbs':20.1,'fat':0.1,'fiber':3.0,'weights':{'unidade':130.0,'porcao':100.0,'grama':1.0}},
  'mandioca': {'cal_100g':125,'protein':1.0,'carbs':30.1,'fat':0.3,'fiber':1.8,'weights':{'pedaco':80.0,'porcao':100.0,'grama':1.0}},
  'miojo': {'cal_100g':450,'protein':9.0,'carbs':60.0,'fat':19.0,'fiber':2.0,'weights':{'pacote':85.0,'grama':1.0}},
  'salada': {'cal_100g':20,'protein':1.0,'carbs':3.5,'fat':0.2,'fiber':1.8,'weights':{'porcao':100.0,'grama':1.0}},
  'legumes': {'cal_100g':35,'protein':1.8,'carbs':6.5,'fat':0.3,'fiber':2.5,'weights':{'porcao':100.0,'grama':1.0}},
  'brocolis': {'cal_100g':35,'protein':2.4,'carbs':7.2,'fat':0.4,'fiber':3.3,'weights':{'porcao':100.0,'grama':1.0}},
  'cenoura': {'cal_100g':41,'protein':0.9,'carbs':9.6,'fat':0.2,'fiber':2.8,'weights':{'unidade':60.0,'grama':1.0}},
  'tomate': {'cal_100g':18,'protein':0.9,'carbs':3.9,'fat':0.2,'fiber':1.2,'weights':{'unidade':100.0,'grama':1.0}},
  'macarrao': {'cal_100g':131,'protein':5.0,'carbs':25.0,'fat':1.1,'fiber':1.8,'weights':{'colher':20.0,'xicara':140.0,'grama':1.0}},
  'pao': {'cal_100g':265,'protein':9.0,'carbs':49.0,'fat':3.2,'fiber':2.7,'weights':{'fatia':30.0,'unidade':50.0,'grama':1.0}},
  'queijo': {'cal_100g':350,'protein':23.0,'carbs':2.0,'fat':28.0,'fiber':0.0,'weights':{'fatia':20.0,'pedaco':30.0,'grama':1.0}},
  'presunto': {'cal_100g':145,'protein':16.0,'carbs':2.0,'fat':8.0,'fiber':0.0,'weights':{'fatia':20.0,'grama':1.0}},
  'cuscuz': {'cal_100g':112,'protein':2.3,'carbs':25.0,'fat':0.5,'fiber':1.7,'weights':{'porcao':150.0,'xicara':150.0,'grama':1.0}},
  'tapioca': {'cal_100g':230,'protein':0.2,'carbs':57.0,'fat':0.0,'fiber':0.0,'weights':{'unidade':70.0,'porcao':70.0,'grama':1.0}},
  'banana': {'cal_100g':89,'protein':1.1,'carbs':22.8,'fat':0.3,'fiber':2.6,'weights':{'unidade':90.0,'grama':1.0}},
  'aveia': {'cal_100g':394,'protein':13.9,'carbs':66.6,'fat':8.5,'fiber':9.1,'weights':{'colher':15.0,'grama':1.0}},
  'iogurte': {'cal_100g':61,'protein':3.5,'carbs':4.7,'fat':3.3,'fiber':0.0,'weights':{'pote':170.0,'grama':1.0}},
  'abacate': {'cal_100g':96,'protein':1.2,'carbs':6.0,'fat':8.4,'fiber':6.3,'weights':{'porcao':100.0,'grama':1.0}},
  'farofa': {'cal_100g':365,'protein':2.5,'carbs':70.0,'fat':8.0,'fiber':3.0,'weights':{'colher':20.0,'porcao':50.0,'grama':1.0}},
  'lentilha': {'cal_100g':116,'protein':9.0,'carbs':20.0,'fat':0.4,'fiber':7.9,'weights':{'concha':120.0,'colher':30.0,'grama':1.0}},
};

const List<String> availableFoodNames = ['arroz','arroz integral','feijão','frango','carne','peixe','ovo','batata','batata frita','batata-doce','mandioca','miojo','salada','legumes','brócolis','cenoura','tomate','macarrão','pão','queijo','presunto','cuscuz','tapioca','banana','aveia','iogurte','abacate','farofa','lentilha','atum','omelete','refrigerante','biscoito','salsicha','nugget','salgadinho'];

MealItemAnalysis analyzeFoodItem(String food, double qty, String unit) {
  final key = normalizeMealText(food).replaceAll(' ', '_');
  const humanNames = {'batata_frita':'Batata Frita','arroz_integral':'Arroz Integral','arroz':'Arroz','feijao':'Feijão','frango':'Frango','ovo':'Ovo','miojo':'Miojo','salada':'Salada','macarrao':'Macarrão','pao':'Pão','brocolis':'Brócolis','batata-doce':'Batata-doce'};
  const carbos = {'arroz','arroz_integral','macarrao','batata','pao','tapioca','cuscuz','farofa','mandioca','aveia','batata_frita','batata-doce'};
  const proteins = {'carne','frango','peixe','ovo','feijao','lentilha','queijo','atum','iogurte'};
  const fibers = {'salada','legumes','brocolis','cenoura','tomate','banana','abobora','abacate'};
  const processed = {'miojo':'Ultraprocessado: rico em sódio e com baixa variedade de alimentos.','salsicha':'Alimento processado que pode ter alto teor de sódio.','nugget':'Ultraprocessado que costuma combinar farinha, gordura e sódio.','refrigerante':'Bebida açucarada com pouco valor nutricional.','biscoito':'Pode concentrar farinha refinada, gordura e/ou açúcar.','salgadinho':'Geralmente rico em sódio e gordura.','batata_frita':'Preparação geralmente mais densa em energia, gordura e sódio.'};
  final db = foodDatabase[key];
  final weights = db == null ? <String,double>{} : (db['weights'] as Map).map((k,v) => MapEntry(k.toString(), (v as num).toDouble()));
  final factor = qty * (weights[unit] ?? (weights.isEmpty ? 1.0 : weights.values.first)) / 100.0;
  num value(String field) => db == null ? 0 : (db[field] as num? ?? 0);
  final type = processed.containsKey(key) ? 'processed' : proteins.contains(key) ? 'protein' : carbos.contains(key) ? 'carb' : fibers.contains(key) ? 'fiber' : 'unknown';
  final detail = processed[key] ?? (type == 'protein' ? 'Fonte de proteína que contribui para manutenção muscular e saciedade.' : type == 'carb' ? 'Fonte de energia para o organismo.' : type == 'fiber' ? 'Contribui para a saúde intestinal e maior saciedade.' : 'Alimento identificado.');
  final name = humanNames[key] ?? (food.isEmpty ? 'Alimento' : food[0].toUpperCase() + food.substring(1));
  return MealItemAnalysis(name:type == 'processed' ? 'Ultraprocessado' : type == 'protein' ? 'Proteína' : type == 'carb' ? 'Carboidrato' : type == 'fiber' ? 'Fibra' : 'Alimento', foodName:name, type:type, isWarning:processed.containsKey(key), detail:detail, caloriesPer100g:db == null ? 0 : db['cal_100g'] as num, unitWeights:weights, actualCalories:value('cal_100g').toDouble()*factor, actualProtein:value('protein').toDouble()*factor, actualCarbs:value('carbs').toDouble()*factor, actualFat:value('fat').toDouble()*factor, actualFiber:value('fiber').toDouble()*factor);
}

double portionStep(String unit) => (unit == 'grama' || unit == 'g') ? 10 : 1;

MealAnalysisReport reportFromItems(String input, List<MealItemAnalysis> items, num? calories) {
  final protein = items.fold<double>(0,(s,i)=>s+i.protein), carbs = items.fold<double>(0,(s,i)=>s+i.carbs), fat = items.fold<double>(0,(s,i)=>s+i.fat), fiber = items.fold<double>(0,(s,i)=>s+i.fiber), total = items.fold<double>(0,(s,i)=>s+i.calories);
  final catalog = _feedbackByCanonical[_canonical(items.map((i)=>i.foodName).join(' '))];
  if (catalog != null) return MealAnalysisReport(overallTitle:catalog.title, overallStatus:catalog.status, overallBody:catalog.body, improvement:catalog.improvement, itemDetails:items, totalCalories:calories ?? total, protein:protein, carbs:carbs, fat:fat, fiber:fiber);
  final hasProcessed=items.any((i)=>i.isWarning), hasProtein=items.any((i)=>i.type=='protein'), hasCarb=items.any((i)=>i.type=='carb'), hasFiber=items.any((i)=>i.type=='fiber');
  String title,status,body,improvement;
  if(hasProcessed){title='Alerta de Processados';status='important';body='Sua refeição contém um alimento processado ou ultraprocessado. Observe especialmente sódio, açúcares e gorduras conforme o produto.';improvement='Quando possível, combine com alimentos in natura e varie as fontes de proteína e vegetais.';} else if(hasProtein&&hasCarb&&hasFiber){title='Prato Equilibrado!';status='positive';body='A refeição combina fonte de energia, proteína e alimentos vegetais ricos em fibras.';improvement='Varie os legumes e verduras e ajuste as porções ao seu contexto alimentar.';} else if(!hasProtein){title='Falta Proteína';status='attention';body='A refeição fornece energia, mas não foi identificada uma fonte clara de proteína.';improvement='Considere ovos, frango, peixe, tofu ou leguminosas.';} else if(!hasFiber){title='Faltam Fibras';status='attention';body='Há uma fonte de proteína, mas faltam alimentos vegetais ricos em fibras na combinação identificada.';improvement='Adicione salada, legumes, verduras ou uma fruta.';} else if(!hasCarb){title='Baixo Carboidrato';status='information';body='A combinação identificada tem proteína e/ou fibras, mas pouca fonte de carboidrato.';improvement='Se fizer sentido para sua alimentação, inclua uma porção de arroz, batata, mandioca ou outro carboidrato.';} else {title='Análise Geral';status='information';body='Analisamos os alimentos identificados na refeição.';improvement='Varie grupos alimentares e ajuste as porções ao longo do dia.';}
  return MealAnalysisReport(overallTitle:title,overallStatus:status,overallBody:body,improvement:improvement,itemDetails:items,totalCalories:calories ?? total,protein:protein,carbs:carbs,fat:fat,fiber:fiber);
}

MealAnalysisReport findMealAnalysisSmart(String input, num? calories) {
  final normalized=normalizeMealText(input);
  final parts=normalized.split(',').map((s)=>s.trim()).where((s)=>s.isNotEmpty).toList();
  const units={'colher','concha','pacote','unidade','fatia','porcao','grama','g','xicara','pedaco','ovo','bife','file','pote'};
  final items=<MealItemAnalysis>[];
  for(final part in parts){
    final words=part.split(RegExp(r'\s+'));
    final numberIndex=words.indexWhere((w)=>double.tryParse(w)!=null);
    final qty=numberIndex>=0?double.parse(words[numberIndex]):1.0;
    final unit=numberIndex>=0&&numberIndex+1<words.length&&units.contains(words[numberIndex+1])?words[numberIndex+1]:'unidade';
    final foods=words.where((w)=>(numberIndex<0||w!=words[numberIndex])&&!units.contains(w)).toList();
    for(final food in foods){
      items.add(analyzeFoodItem(food,foods.length==1?qty:1,foods.length==1?unit:'unidade'));
    }
  }
  if(items.isEmpty){
    for (final food in normalized.split(' ').where((w) => w.isNotEmpty && !units.contains(w))) {
      items.add(analyzeFoodItem(food, 1, 'unidade'));
    }
  }
  return reportFromItems(input,items,calories);
}
