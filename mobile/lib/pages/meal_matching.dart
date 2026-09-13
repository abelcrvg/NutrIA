import 'package:flutter/material.dart';
import '../models/meal_feedback.dart';
import 'meal_feedback_extra.dart';

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e','í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c'};
  replacements.forEach((from,to)=>value=value.replaceAll(from,to));
  value = value.replaceAll('batata frita', 'batata_frita');
  value = value.replaceAll('arroz integral', 'arroz_integral');
  value = value.replaceAll('batata doce', 'batata-doce');
  const aliases={'refri':'refrigerante','burguer':'hamburguer','paes':'pao','ovos':'ovo','feijoes':'feijao','brocolis':'brocolis'};
  const ignored={'e','com','de','da','do','das','dos'};
  value=value.replaceAll(RegExp(r'[^a-z0-9\s_-]+'),' ');
  return value.split(RegExp(r'\s+')).where((w)=>w.isNotEmpty && !ignored.contains(w)).map((w)=>aliases[w]??w).join(' ');
}

String _canonical(String input){
  final words=normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toList()..sort();
  return words.join('|');
}

final Map<String, MealFeedback> _feedbackByCanonical = {
  for (final entry in mealFeedbackExtras.entries) _canonical(entry.key): entry.value,
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

const List<String> availableFoodNames = [
  'arroz','arroz integral','feijão','frango','carne','peixe','ovo','batata','batata frita','batata-doce','mandioca','miojo','salada','legumes','brócolis','cenoura','tomate','macarrão','pão','queijo','presunto','cuscuz','tapioca','banana','aveia','iogurte','abacate','farofa','lentilha','atum','omelete','refrigerante','biscoito','salsicha','nugget','salgadinho'
];

MealItemAnalysis analyzeFoodItem(String food, double qty, String unit) {
  final key=normalizeMealText(food).replaceAll(' ', '_');
  final humanNames={'batata_frita':'Batata Frita','arroz_integral':'Arroz Integral','arroz':'Arroz','feijao':'Feijão','frango':'Frango','ovo':'Ovo','miojo':'Miojo','salada':'Salada','macarrao':'Macarrão','pao':'Pão','brocolis':'Brócolis','batata-doce':'Batata-doce'};
  const carbos={'arroz','arroz_integral','macarrao','batata','pao','tapioca','cuscuz','farofa','mandioca','milho','aveia','massa','batata_frita','batata-doce'};
  const proteins={'carne','frango','peixe','ovo','feijao','lentilha','grao-de-bico','queijo','leite','soja','tofu','atum','iogurte'};
  const fibers={'salada','legumes','verduras','brocolis','alface','cenoura','abobrinha','tomate','fruta','banana','maca','laranja','espinafre','abobora','abacate'};
  const processed={'miojo':'Ultraprocessado: rico em sódio e com baixa variedade de alimentos.','salsicha':'Alimento processado que pode ter alto teor de sódio.','nugget':'Ultraprocessado que costuma combinar farinha, gordura e sódio.','refrigerante':'Bebida açucarada com pouco valor nutricional.','biscoito':'Pode concentrar farinha refinada, gordura e/ou açúcar.','salgadinho':'Geralmente rico em sódio e gordura.','batata_frita':'Preparação geralmente mais densa em energia, gordura e sódio.'};
  final dbInfo=foodDatabase[key];
  final foodName=humanNames[key]??food[0].toUpperCase()+food.substring(1);
  final calPer100=dbInfo!=null?(dbInfo['cal_100g'] as num).toDouble():0.0;
  final Map<String,double> weights=dbInfo==null?<String,double>{}:(dbInfo['weights'] as Map).map((k,v)=>MapEntry(k.toString(),(v as num).toDouble()));
  final grams=qty*(weights[unit]??weights.values.firstOrNull??1.0);
  final factor=grams/100;
  final cal=calPer100*factor;
  final protein=(dbInfo?['protein'] as num? ?? 0).toDouble()*factor;
  final carbs=(dbInfo?['carbs'] as num? ?? 0).toDouble()*factor;
  final fat=(dbInfo?['fat'] as num? ?? 0).toDouble()*factor;
  final fiber=(dbInfo?['fiber'] as num? ?? 0).toDouble()*factor;
  final type=processed.containsKey(key)?'processed':proteins.contains(key)?'protein':carbos.contains(key)?'carb':fibers.contains(key)?'fiber':'unknown';
  final detail=processed[key]??(type=='protein'?'Fonte de proteína que contribui para manutenção muscular e saciedade.':type=='carb'?'Fonte de energia para o organismo.':type=='fiber'?'Contribui para a saúde intestinal e maior saciedade.':'Alimento identificado.');
  return MealItemAnalysis(name:type=='processed'?'Ultraprocessado':type=='protein'?'Proteína':type=='carb'?'Carboidrato':type=='fiber'?'Fibra':'Alimento',foodName:foodName,type:type,isWarning:processed.containsKey(key),detail:detail,caloriesPer100g:calPer100,unitWeights:weights,actualCalories:cal,actualProtein:protein,actualCarbs:carbs,actualFat:fat,actualFiber:fiber);
}

double portionStep(String unit) {
  if (unit=='grama' || unit=='g') return 10;
  if (unit=='unidade' || unit=='ovo' || unit=='fatia') return 1;
  return 1;
}

MealAnalysisReport findMealAnalysisSmart(String input, num? calories) {
  final normalized=normalizeMealText(input);
  final rawParts=normalized.split(',').map((s)=>s.trim()).where((s)=>s.isNotEmpty).toList();
  const commonUnits={'colher','concha','pacote','unidade','fatia','porcao','grama','g','xicara','pedaco','ovo','bife','file','pote'};
  final List<MealItemAnalysis> itemDetails=[];
  final parsedFoods=<String>[];
  for(final part in rawParts){
    final words=part.split(RegExp(r'\s+'));
    final numIdx=words.indexWhere((w)=>double.tryParse(w)!=null);
    final qty=numIdx==-1?1.0:double.parse(words[numIdx]);
    var unit='unidade';
    if(numIdx!=-1 && numIdx+1<words.length && commonUnits.contains(words[numIdx+1])) unit=words[numIdx+1];
    final foodWords=words.where((w)=>double.tryParse(w)==null && !commonUnits.contains(w)).toList();
    if(foodWords.length==1){parsedFoods.add(foodWords.first);itemDetails.add(analyzeFoodItem(foodWords.first,qty,unit));}
    else if(foodWords.length>1){for(final food in foodWords){parsedFoods.add(food);itemDetails.add(analyzeFoodItem(food,1.0,'unidade'));}}
  }
  if(rawParts.length==1 && parsedFoods.length<=1){
    final tokens=normalized.split(' ').where((w)=>w.isNotEmpty && !commonUnits.contains(w) && double.tryParse(w)==null).toList();
    if(tokens.length>1){itemDetails.clear();parsedFoods.clear();for(final food in tokens){parsedFoods.add(food);itemDetails.add(analyzeFoodItem(food,1.0,'unidade'));}}
  }
  final total=itemDetails.fold<double>(0,(s,i)=>s+i.calories);
  final protein=itemDetails.fold<double>(0,(s,i)=>s+i.protein);
  final carbs=itemDetails.fold<double>(0,(s,i)=>s+i.carbs);
  final fat=itemDetails.fold<double>(0,(s,i)=>s+i.fat);
  final fiber=itemDetails.fold<double>(0,(s,i)=>s+i.fiber);
  final catalog=_feedbackByCanonical[_canonical(parsedFoods.join(' '))];
  if(catalog!=null)return MealAnalysisReport(overallTitle:catalog.title,overallStatus:catalog.status,overallBody:catalog.body,improvement:catalog.improvement,itemDetails:itemDetails,totalCalories:calories??total,protein:protein,carbs:carbs,fat:fat,fiber:fiber);
  final hasProcessed=itemDetails.any((i)=>i.isWarning),hasProtein=itemDetails.any((i)=>i.type=='protein'),hasCarb=itemDetails.any((i)=>i.type=='carb'),hasFiber=itemDetails.any((i)=>i.type=='fiber');
  String title,status,body,improvement;
  if(hasProcessed){title='Alerta de Processados';status='important';body='Sua refeição contém um alimento processado ou ultraprocessado. Observe especialmente sódio, açúcares e gorduras conforme o produto.';improvement='Quando possível, combine com alimentos in natura e varie as fontes de proteína e vegetais.';}
  else if(hasProtein&&hasCarb&&hasFiber){title='Prato Equilibrado!';status='positive';body='A refeição combina fonte de energia, proteína e alimentos vegetais ricos em fibras.';improvement='Varie os legumes e verduras e ajuste as porções ao seu contexto alimentar.';}
  else if(!hasProtein){title='Falta Proteína';status='attention';body='A refeição fornece energia, mas não foi identificada uma fonte clara de proteína.';improvement='Considere ovos, frango, peixe, tofu ou leguminosas.';}
  else if(!hasFiber){title='Faltam Fibras';status='attention';body='Há uma fonte de proteína, mas faltam alimentos vegetais ricos em fibras na combinação identificada.';improvement='Adicione salada, legumes, verduras ou uma fruta.';}
  else if(!hasCarb){title='Baixo Carboidrato';status='information';body='A combinação identificada tem proteína e/ou fibras, mas pouca fonte de carboidrato.';improvement='Se fizer sentido para sua alimentação, inclua uma porção de arroz, batata, mandioca ou outro carboidrato.';}
  else{title='Análise Geral';status='information';body='Analisamos os alimentos identificados na refeição.';improvement='Varie grupos alimentares e ajuste as porções ao longo do dia.';}
  return MealAnalysisReport(overallTitle:title,overallStatus:status,overallBody:body,improvement:improvement,itemDetails:itemDetails,totalCalories:calories??total,protein:protein,carbs:carbs,fat:fat,fiber:fiber);
}

IconData feedbackIcon(String status){switch(status){case 'positive':return Icons.check_circle_outline;case 'attention':return Icons.warning_amber_outlined;case 'important':return Icons.error_outline;default:return Icons.info_outline;}}