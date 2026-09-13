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
  value=value.replaceAll(RegExp(r'[^a-z0-9\s_-]+'),' ');
  const aliases={'refri':'refrigerante','burguer':'hamburguer','paes':'pao','ovos':'ovo','feijoes':'feijao'};
  const ignored={'e','com','de','da','do','das','dos'};
  return value.split(RegExp(r'\s+')).where((w)=>w.isNotEmpty && !ignored.contains(w)).map((w)=>aliases[w]??w).join(' ');
}

String _canonical(String input){
  final words=normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toList()..sort();
  return words.join('|');
}

final Map<String, MealFeedback> _feedbackByCanonical = {
  for (final entry in mealFeedbackExtras.entries) _canonical(entry.key): entry.value,
};

const Map<String, Map<String, dynamic>> FOOD_DATABASE = {
  'arroz': {'cal_100g': 130, 'weights': {'colher': 25.0, 'xicara': 150.0, 'grama': 1.0}},
  'arroz_integral': {'cal_100g': 123, 'weights': {'colher': 25.0, 'xicara': 150.0, 'grama': 1.0}},
  'feijao': {'cal_100g': 91, 'weights': {'colher': 30.0, 'concha': 120.0, 'grama': 1.0}},
  'frango': {'cal_100g': 165, 'weights': {'pedaco': 100.0, 'grama': 1.0}},
  'ovo': {'cal_100g': 155, 'weights': {'unidade': 50.0, 'ovo': 50.0, 'grama': 1.0}},
  'batata_frita': {'cal_100g': 312, 'weights': {'porcao': 100.0, 'grama': 1.0}},
  'miojo': {'cal_100g': 450, 'weights': {'pacote': 85.0, 'grama': 1.0}},
  'salada': {'cal_100g': 20, 'weights': {'porcao': 100.0, 'grama': 1.0}},
  'macarrao': {'cal_100g': 131, 'weights': {'colher': 20.0, 'xicara': 140.0, 'grama': 1.0}},
  'pao': {'cal_100g': 265, 'weights': {'fatia': 30.0, 'unidade': 50.0, 'grama': 1.0}},
};

MealItemAnalysis _analyzeItem(String item, double qty, String unit) {
  final humanNames = {'batata_frita':'Batata Frita','arroz_integral':'Arroz Integral','arroz':'Arroz','feijao':'Feijão','frango':'Frango','ovo':'Ovo','miojo':'Miojo','salada':'Salada','macarrao':'Macarrão','pao':'Pão'};
  const carbos={'arroz','arroz_integral','macarrao','batata','pao','tapioca','cuscuz','farofa','mandioca','milho','aveia','massa','batata_frita','batata-doce'};
  const proteins={'carne','frango','peixe','ovo','feijao','lentilha','grao-de-bico','queijo','leite','soja','tofu','atum','iogurte'};
  const fibers={'salada','legumes','verduras','brocolis','alface','cenoura','abobrinha','tomate','fruta','banana','maca','laranja','espinafre','abobora','abacate'};
  const processed={'miojo':'Ultraprocessado: rico em sódio e com baixa variedade de alimentos.','salsicha':'Alimento processado que pode ter alto teor de sódio.','nugget':'Ultraprocessado que costuma combinar farinha, gordura e sódio.','refrigerante':'Bebida açucarada com pouco valor nutricional.','biscoito':'Pode concentrar farinha refinada, gordura e/ou açúcar.','salgadinho':'Geralmente rico em sódio e gordura.','batata_frita':'Preparação geralmente mais densa em energia, gordura e sódio.'};
  final foodName=humanNames[item]??item.replaceAll('_',' ').toUpperCase();
  final dbInfo=FOOD_DATABASE[item];
  final calPer100=dbInfo!=null?(dbInfo['cal_100g'] as num).toDouble():0.0;
  final Map<String,double> weights=dbInfo==null?<String,double>{}:(dbInfo['weights'] as Map).map((key,value)=>MapEntry(key.toString(),(value as num).toDouble()));
  final finalCalories=dbInfo==null?0.0:(qty*(weights[unit]??1.0)*calPer100)/100;
  if(processed.containsKey(item))return MealItemAnalysis(name:'Ultraprocessado',foodName:foodName,type:'processed',isWarning:true,detail:processed[item]!,caloriesPer100g:calPer100,unitWeights:weights,actualCalories:finalCalories);
  if(proteins.contains(item))return MealItemAnalysis(name:'Proteína',foodName:foodName,type:'protein',isWarning:false,detail:'Fonte de proteína que contribui para manutenção muscular e saciedade.',caloriesPer100g:calPer100,unitWeights:weights,actualCalories:finalCalories);
  if(carbos.contains(item))return MealItemAnalysis(name:'Carboidrato',foodName:foodName,type:'carb',isWarning:false,detail:'Fonte de energia para o organismo.',caloriesPer100g:calPer100,unitWeights:weights,actualCalories:finalCalories);
  if(fibers.contains(item))return MealItemAnalysis(name:'Fibra',foodName:foodName,type:'fiber',isWarning:false,detail:'Contribui para a saúde intestinal e maior saciedade.',caloriesPer100g:calPer100,unitWeights:weights,actualCalories:finalCalories);
  return MealItemAnalysis(name:item,foodName:foodName,type:'unknown',isWarning:false,detail:'Alimento identificado.',caloriesPer100g:calPer100,unitWeights:weights,actualCalories:finalCalories);
}

MealAnalysisReport findMealAnalysisSmart(String input, num? calories) {
  final normalized=normalizeMealText(input);
  final rawParts=normalized.split(',').map((s)=>s.trim()).where((s)=>s.isNotEmpty).toList();
  final commonUnits={'colher','concha','pacote','unidade','fatia','porcao','grama','g','xicara','pedaco','ovo'};
  final List<MealItemAnalysis> itemDetails=[];
  double calculatedTotalCals=0;
  final parsedFoods=<String>[];

  for(final part in rawParts){
    final words=part.split(RegExp(r'\s+'));
    final numIdx=words.indexWhere((w)=>double.tryParse(w)!=null);
    final qty=numIdx==-1?1.0:double.parse(words[numIdx]);
    var unit='unidade';
    if(numIdx!=-1 && numIdx+1<words.length && commonUnits.contains(words[numIdx+1])) unit=words[numIdx+1];
    final foodWords=words.where((w)=>!double.tryParse(w).toString().contains('true') && (numIdx==-1 || w!=words[numIdx]) && !commonUnits.contains(w)).toList();
    if(foodWords.length==1){parsedFoods.add(foodWords.first);final a=_analyzeItem(foodWords.first,qty,unit);itemDetails.add(a);calculatedTotalCals+=a.calories;}
    else if(foodWords.length>1){
      for(final food in foodWords){parsedFoods.add(food);final a=_analyzeItem(food,1.0,'unidade');itemDetails.add(a);calculatedTotalCals+=a.calories;}
    }
  }

  if(rawParts.length==1 && parsedFoods.length<=1){
    final tokens=normalized.split(' ').where((w)=>w.isNotEmpty && !commonUnits.contains(w) && double.tryParse(w)==null).toList();
    if(tokens.length>1){
      itemDetails.clear(); parsedFoods.clear(); calculatedTotalCals=0;
      for(final food in tokens){parsedFoods.add(food);final a=_analyzeItem(food,1.0,'unidade');itemDetails.add(a);calculatedTotalCals+=a.calories;}
    }
  }

  final catalog=_feedbackByCanonical[_canonical(parsedFoods.join(' '))];
  if(catalog!=null){
    return MealAnalysisReport(overallTitle:catalog.title,overallStatus:catalog.status,overallBody:catalog.body,improvement:catalog.improvement,itemDetails:itemDetails,totalCalories:calories??calculatedTotalCals);
  }

  final hasProcessed=itemDetails.any((i)=>i.isWarning),hasProtein=itemDetails.any((i)=>i.type=='protein'),hasCarb=itemDetails.any((i)=>i.type=='carb'),hasFiber=itemDetails.any((i)=>i.type=='fiber');
  String title,status,body,improvement;
  if(hasProcessed){title='Alerta de Processados';status='important';body='Sua refeição contém um alimento processado ou ultraprocessado. Observe especialmente sódio, açúcares e gorduras conforme o produto.';improvement='Quando possível, combine com alimentos in natura e varie as fontes de proteína e vegetais.';}
  else if(hasProtein&&hasCarb&&hasFiber){title='Prato Equilibrado!';status='positive';body='A refeição combina fonte de energia, proteína e alimentos vegetais ricos em fibras.';improvement='Varie os legumes e verduras e ajuste as porções ao seu contexto alimentar.';}
  else if(!hasProtein){title='Falta Proteína';status='attention';body='A refeição fornece energia, mas não foi identificada uma fonte clara de proteína.';improvement='Considere ovos, frango, peixe, tofu ou leguminosas.';}
  else if(!hasFiber){title='Faltam Fibras';status='attention';body='Há uma fonte de proteína, mas faltam alimentos vegetais ricos em fibras na combinação identificada.';improvement='Adicione salada, legumes, verduras ou uma fruta.';}
  else if(!hasCarb){title='Baixo Carboidrato';status='information';body='A combinação identificada tem proteína e/ou fibras, mas pouca fonte de carboidrato.';improvement='Se fizer sentido para sua alimentação, inclua uma porção de arroz, batata, mandioca ou outro carboidrato.';}
  else{title='Análise Geral';status='information';body='Analisamos os alimentos identificados na refeição.';improvement='Varie grupos alimentares e ajuste as porções ao longo do dia.';}
  return MealAnalysisReport(overallTitle:title,overallStatus:status,overallBody:body,improvement:improvement,itemDetails:itemDetails,totalCalories:calories??calculatedTotalCals);
}

IconData feedbackIcon(String status){switch(status){case 'positive':return Icons.check_circle_outline;case 'attention':return Icons.warning_amber_outlined;case 'important':return Icons.error_outline;default:return Icons.info_outline;}}
