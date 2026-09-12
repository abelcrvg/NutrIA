import 'package:flutter/material.dart';
import '../models/meal_feedback.dart';
import '../services/feedback_service.dart';

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e','í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c'};
  replacements.forEach((from,to)=>value=value.replaceAll(from,to));

  // Protect compound foods
  value = value.replaceAll('batata frita', 'batata_frita');
  value = value.replaceAll('arroz integral', 'arroz_integral');

  value=value.replaceAll(RegExp(r'[^a-z0-9\s_]+'),' ');
  const aliases={'refri':'refrigerante','burguer':'hamburguer','pao':'pao'};
  return value.split(RegExp(r'\s+')).where((w)=>w.isNotEmpty).map((w)=>aliases[w]??w).join(' ');
}

String _canonical(String input){
  final words=normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toList()..sort();
  return words.join('|');
}

const Map<String, Map<String, dynamic>> FOOD_DATABASE = {
  'arroz': {'cal_100g': 130, 'weights': {'colher': 25, 'xicara': 150}},
  'feijao': {'cal_100g': 91, 'weights': {'colher': 30, 'concha': 120}},
  'frango': {'cal_100g': 165, 'weights': {'pedaco': 100, 'grama': 1}},
  'ovo': {'cal_100g': 155, 'weights': {'unidade': 50, 'ovo': 50}},
  'batata_frita': {'cal_100g': 312, 'weights': {'porcao': 100, 'grama': 1}},
  'miojo': {'cal_100g': 450, 'weights': {'pacote': 85, 'grama': 1}},
  'salada': {'cal_100g': 20, 'weights': {'porcao': 100, 'grama': 1}},
  'macarrao': {'cal_100g': 131, 'weights': {'colher': 20, 'xicara': 140}},
  'pao': {'cal_100g': 265, 'weights': {'fatia': 30, 'unidade': 50}},
};

MealItemAnalysis _analyzeItem(String item, double qty, String unit) {
  final humanNames = {
    'batata_frita': 'Batata Frita',
    'arroz_integral': 'Arroz Integral',
    'arroz': 'Arroz',
    'feijao': 'Feijão',
    'frango': 'Frango',
    'ovo': 'Ovo',
    'miojo': 'Miojo',
    'salada': 'Salada',
    'macarrao': 'Macarrão',
    'pao': 'Pão',
  };

  const carbos = {'arroz', 'macarrao', 'batata', 'pao', 'tapioca', 'cuscuz', 'farofa', 'mandioca', 'milho', 'aveia', 'massa', 'batata_frita'};
  const proteins = {'carne', 'frango', 'peixe', 'ovo', 'feijao', 'lentilha', 'grao-de-bico', 'queijo', 'leite', 'soja', 'tofu'};
  const fibers = {'salada', 'legumes', 'verduras', 'brocolis', 'alface', 'cenoura', 'abobrinha', 'tomate', 'fruta', 'banana', 'maca', 'laranja', 'espinafre'};
  const processed = {
    'miojo': 'Ultraprocessado: rico em sódio e glutamato monossódico, que podem causar retenção de líquidos e pressão alta.',
    'salsicha': 'Ultraprocessado: contém nitritos e nitratos, conservantes associados a riscos à saúde a longo prazo.',
    'nugget': 'Ultraprocessado: baixa quantidade de proteína real, rico em farinhas e gorduras saturadas.',
    'refrigerante': 'Açúcar em excesso e corantes artificiais que prejudicam a saúde metabólica e a insulina.',
    'biscoito': 'Rico em farinha refinada e gorduras trans, oferecendo calorias vazias e pouca saciedade.',
    'salgadinho': 'Excesso de sódio e realçadores de sabor artificiais que sobrecarregam os rins.',
    'batata_frita': 'Processado: alto teor de gorduras saturadas e sódio.',
  };

  String foodName = humanNames[item] ?? (item.replaceAll('_', ' ').toUpperCase());

  final dbInfo = FOOD_DATABASE[item];
  final calPer100 = dbInfo != null ? (dbInfo['cal_100g'] as num).toDouble() : 0.0;
  final weights = dbInfo != null ? Map<String, double>.from(dbInfo['weights']) : {};

  // Calculate actual calories based on quantity and unit
  double finalCalories = 0.0;
  if (dbInfo != null) {
    final weightInGrams = weights[unit] ?? 1.0; // Default to 1g if unit unknown
    final totalGrams = qty * weightInGrams;
    finalCalories = (totalGrams * calPer100) / 100;
  }

  if (processed.containsKey(item)) {
    return MealItemAnalysis(name: 'Ultraprocessado', foodName: foodName, type: 'processed', isWarning: true, detail: processed[item]!, caloriesPer100g: calPer100, unitWeights: weights, actualCalories: finalCalories);
  }
  if (proteins.contains(item)) {
    return MealItemAnalysis(name: 'Proteína', foodName: foodName, type: 'protein', isWarning: false, detail: 'Essencial para a construção muscular e controle da fome.', caloriesPer100g: calPer100, unitWeights: weights, actualCalories: finalCalories);
  }
  if (carbos.contains(item)) {
    return MealItemAnalysis(name: 'Carboidrato', foodName: foodName, type: 'carb', isWarning: false, detail: 'Fonte primária de energia para o cérebro e músculos.', caloriesPer100g: calPer100, unitWeights: weights, actualCalories: finalCalories);
  }
  if (fibers.contains(item)) {
    return MealItemAnalysis(name: 'Fibra', foodName: foodName, type: 'fiber', isWarning: false, detail: 'Essencial para a saúde intestinal e controle da glicemia.', caloriesPer100g: calPer100, unitWeights: weights, actualCalories: finalCalories);
  }
  return MealItemAnalysis(name: item, foodName: foodName, type: 'unknown', isWarning: false, detail: 'Alimento identificado.', caloriesPer100g: calPer100, unitWeights: weights, actualCalories: finalCalories);
}


/// Main analysis engine
MealAnalysisReport findMealAnalysisSmart(String input, num? calories) {
  final parts = input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  List<MealItemAnalysis> itemDetails = [];
  double calculatedTotalCals = 0;

  for (final part in parts) {
    // Simple parser: looks for "number unit food" or "food number unit"
    // Example: "arroz 2 colheres" or "2 colheres de arroz"
    final normalizedPart = normalizeMealText(part);
    final words = normalizedPart.split(' ');

    double qty = 1.0;
    String unit = 'unidade';
    String food = '';

    // Try to find a number
    int numIdx = words.indexWhere((w) => double.tryParse(w) != null);
    if (numIdx != -1) {
      qty = double.parse(words[numIdx]);
      // Check if next word is a unit
      if (numIdx + 1 < words.length) {
        unit = words[numIdx + 1];
      }
    }

    // Determine the food name (the part that isn't a number or a common unit)
    final commonUnits = {'colher', 'concha', 'pacote', 'unidade', 'fatia', 'porcao', 'grama', 'g'};
    final foodWords = words.where((w) => w != (numIdx != -1 ? words[numIdx] : '') && !commonUnits.contains(w) && w != 'de').toList();
    food = foodWords.join('_');

    if (food.isEmpty) {
      // Fallback to the whole part if we couldn't isolate a food name
      food = normalizedPart;
    }

    final analysis = _analyzeItem(food, qty, unit);
    itemDetails.add(analysis);
    calculatedTotalCals += analysis.calories;
  }

  // If input was just a list of foods without commas, handle it
  if (itemDetails.isEmpty && input.isNotEmpty) {
    final words = normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toList();
    itemDetails = words.map((w) => _analyzeItem(w, 1.0, 'unidade')).toList();
    calculatedTotalCals = itemDetails.fold(0.0, (sum, item) => sum + item.calories);
  }

  // 3. Determine Overall Status
  bool hasProcessed = itemDetails.any((i) => i.isWarning);
  bool hasProtein = itemDetails.any((i) => i.type == 'protein');
  bool hasCarb = itemDetails.any((i) => i.type == 'carb');
  bool hasFiber = itemDetails.any((i) => i.type == 'fiber');

  String title, status, body, improvement;

  if (hasProcessed) {
    title = 'Alerta de Processados';
    status = 'important';
    body = 'Sua refeição contém itens ultraprocessados. Esses alimentos geralmente possuem excesso de sódio, açúcares e gorduras artificiais que prejudicam o metabolismo.';
    improvement = 'Tente substituir o ${itemDetails.firstWhere((i) => i.isWarning).foodName} por uma opção natural ou caseira para reduzir a inflamação do corpo.';
  } else if (hasProtein && hasCarb && hasFiber) {
    title = 'Prato Equilibrado!';
    status = 'positive';
    body = 'Parabéns! Você conseguiu combinar os três pilares da nutrição: energia (carbos), construção (proteínas) e saúde intestinal (fibras).';
    improvement = 'Para a próxima refeição, tente variar as cores dos legumes para obter diferentes vitaminas.';
  } else if (!hasProtein) {
    title = 'Falta Proteína';
    status = 'attention';
    body = 'Sua refeição fornece energia, mas falta proteína. A proteína é essencial para a manutenção dos músculos e para manter você saciado por mais tempo.';
    improvement = 'Tente adicionar ovos, frango, peixe, tofu ou leguminosas (como feijão e lentilha).';
  } else if (!hasFiber) {
    title = 'Faltam Fibras';
    status = 'attention';
    body = 'Você tem a base energética e proteica, mas faltam fibras. Elas são cruciais para controlar a velocidade de absorção do açúcar no sangue.';
    improvement = 'Adicione uma porção de salada, legumes cozidos ou uma fruta após a refeição.';
  } else if (!hasCarb) {
    title = 'Baixo Carboidrato';
    status = 'information';
    body = 'Sua refeição está rica em proteínas e fibras, mas baixa em carboidratos. Isso pode ser bom dependendo da sua dieta, mas pode causar fadiga em treinos intensos.';
    improvement = 'Se sentir falta de energia, adicione uma porção moderada de arroz integral, batata-doce ou quinoa.';
  } else {
    title = 'Análise Geral';
    status = 'information';
    body = 'Analisamos a composição do seu prato. Embora não seja perfeitamente equilibrada, ela fornece nutrientes básicos.';
    improvement = 'Busque a regra do prato: metade de vegetais, um quarto de proteína e um quarto de carboidrato.';
  }

  return MealAnalysisReport(
    overallTitle: title,
    overallStatus: status,
    overallBody: body,
    improvement: improvement,
    itemDetails: itemDetails,
    totalCalories: calories ?? calculatedTotalCals,
  );
}

IconData feedbackIcon(String status) {
  switch (status) {
    case 'positive': return Icons.check_circle_outline;
    case 'attention': return Icons.warning_amber_outlined;
    case 'important': return Icons.error_outline;
    default: return Icons.info_outline;
  }
}
