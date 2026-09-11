import 'package:flutter/material.dart';
import '../models/meal_feedback.dart';
import '../services/feedback_service.dart';

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e','í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c'};
  replacements.forEach((from,to)=>value=value.replaceAll(from,to));
  value=value.replaceAll(RegExp(r'[^a-z0-9]+'),' ');
  const aliases={'refri':'refrigerante','burguer':'hamburguer','pao':'pao'};
  return value.split(RegExp(r'\s+')).where((w)=>w.isNotEmpty).map((w)=>aliases[w]??w).join(' ');
}

String _canonical(String input){
  final words=normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toList()..sort();
  return words.join('|');
}

/// Detailed analysis of each ingredient
MealItemAnalysis _analyzeItem(String item) {
  const carbos = {'arroz', 'macarrao', 'batata', 'pao', 'tapioca', 'cuscuz', 'farofa', 'mandioca', 'milho', 'aveia', 'massa'};
  const proteins = {'carne', 'frango', 'peixe', 'ovo', 'feijao', 'lentilha', 'grao-de-bico', 'queijo', 'leite', 'soja', 'tofu'};
  const fibers = {'salada', 'legumes', 'verduras', 'brocolis', 'alface', 'cenoura', 'abobrinha', 'tomate', 'fruta', 'banana', 'maca', 'laranja', 'espinafre'};
  const processed = {
    'miojo': 'Ultraprocessado: rico em sódio e aditivos.',
    'salsicha': 'Ultraprocessado: alto índice de conservantes.',
    'nugget': 'Ultraprocessado: baixo valor nutricional.',
    'refrigerante': 'Açúcar em excesso e corantes.',
    'biscoito': 'Farinha refinada e gordura trans.',
    'salgadinho': 'Excesso de sódio e realçadores artificiais.',
  };

  if (processed.containsKey(item)) {
    return MealItemAnalysis(name: item, type: 'processed', isWarning: true, detail: processed[item]!);
  }
  if (proteins.contains(item)) {
    return const MealItemAnalysis(name: 'Proteína', type: 'protein', isWarning: false, detail: 'Essencial para músculos e saciedade.');
  }
  if (carbos.contains(item)) {
    return const MealItemAnalysis(name: 'Carboidrato', type: 'carb', isWarning: false, detail: 'Fonte primária de energia para o corpo.');
  }
  if (fibers.contains(item)) {
    return const MealItemAnalysis(name: 'Fibra', type: 'fiber', isWarning: false, detail: 'Melhora a digestão e controla a glicemia.');
  }
  return MealItemAnalysis(name: item, type: 'unknown', isWarning: false, detail: 'Alimento identificado.');
}

/// Main analysis engine
MealAnalysisReport findMealAnalysisSmart(String input, num? calories) {
  final normalizedInput = normalizeMealText(input);
  final words = normalizedInput.split(' ').where((w)=>w.isNotEmpty).toList();

  // 1. Try Catalog Match first (Supabase)
  final catalog = FeedbackService().allFeedbacks;
  MealFeedback? catalogFeedback;

  if (catalog.containsKey(normalizedInput)) {
    catalogFeedback = catalog[normalizedInput];
  } else {
    // Partial matching
    MealFeedback? best;
    var bestScore = 0.0;
    for (final entry in catalog.entries) {
      final candidate = entry.key.split(' ').toSet();
      final inputWords = words.toSet();
      if (candidate.isEmpty || !candidate.every(inputWords.contains)) continue;
      final score = candidate.length / inputWords.length;
      if (score > bestScore) {
        bestScore = score;
        best = entry.value;
      }
    }
    if (best != null && bestScore > 0.5) catalogFeedback = best;
  }

  // 2. Break down the meal into items
  final itemDetails = words.map((w) => _analyzeItem(w)).toList();

  // 3. Determine Overall Status
  bool hasProcessed = itemDetails.any((i) => i.isWarning);
  bool hasProtein = itemDetails.any((i) => i.type == 'protein');
  bool hasCarb = itemDetails.any((i) => i.type == 'carb');
  bool hasFiber = itemDetails.any((i) => i.type == 'fiber');

  String title, status, body, improvement;

  if (catalogFeedback != null) {
    title = catalogFeedback.title;
    status = catalogFeedback.status;
    body = catalogFeedback.body;
    improvement = catalogFeedback.improvement;
  } else if (hasProcessed) {
    title = 'Atenção aos Processados';
    status = 'important';
    body = 'Sua refeição contém itens ultraprocessados que podem ser prejudiciais à saúde a longo prazo.';
    improvement = 'Tente substituir os processados por alimentos in natura ou caseiros.';
  } else if (hasProtein && hasCarb && hasFiber) {
    title = 'Refeição Equilibrada';
    status = 'positive';
    body = 'Excelente combinação! Você reuniu os três grupos principais de nutrientes.';
    improvement = 'Mantenha a variedade de cores nos vegetais.';
  } else if (!hasProtein) {
    title = 'Falta Proteína';
    status = 'attention';
    body = 'Sua refeição tem energia, mas falta proteína para os músculos e saciedade.';
    improvement = 'Adicione ovo, frango, peixe ou feijão.';
  } else if (!hasFiber) {
    title = 'Faltam Fibras';
    status = 'attention';
    body = 'Faltam vegetais ou frutas para equilibrar a absorção de nutrientes.';
    improvement = 'Tente adicionar uma porção de salada ou legumes.';
  } else {
    title = 'Análise Geral';
    status = 'information';
    body = 'Analisamos a composição do seu prato com base nos grupos nutricionais.';
    improvement = 'Procure sempre combinar proteínas, carboidratos e fibras.';
  }

  return MealAnalysisReport(
    overallTitle: title,
    overallStatus: status,
    overallBody: body,
    improvement: improvement,
    itemDetails: itemDetails,
    totalCalories: calories ?? 0,
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
