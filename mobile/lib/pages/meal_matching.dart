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
  const carbos = {
    'arroz', 'macarrao', 'batata', 'pao', 'tapioca', 'cuscuz', 'farofa', 'mandioca', 'milho', 'aveia', 'massa',
    'quinoa', 'batata-doce', 'mandioquinha', 'amido', 'trigo', 'cevada', 'centeio'
  };
  const proteins = {
    'carne', 'frango', 'peixe', 'ovo', 'feijao', 'lentilha', 'grao-de-bico', 'queijo', 'leite', 'soja', 'tofu',
    'patinho', 'coxa', 'sobrecoxa', 'atum', 'salmao', 'ricota', 'cottage', 'grão-de-bico'
  };
  const fibers = {
    'salada', 'legumes', 'verduras', 'brocolis', 'alface', 'cenoura', 'abobrinha', 'tomate', 'fruta', 'banana', 'maca', 'laranja', 'espinafre',
    'couve', 'rucula', 'acelga', 'quiabo', 'berinjela', 'chuchu', 'abobora', 'melancia', 'mamao', 'manga', 'pera', 'uva'
  };
  const processed = {
    'miojo': 'Ultraprocessado: rico em sódio e glutamato monossódico, que podem causar retenção de líquidos e pressão alta.',
    'salsicha': 'Ultraprocessado: contém nitritos e nitratos, conservantes associados a riscos à saúde a longo prazo.',
    'nugget': 'Ultraprocessado: baixa quantidade de proteína real, rico em farinhas e gorduras saturadas.',
    'refrigerante': 'Açúcar em excesso e corantes artificiais que prejudicam a saúde metabólica e a insulina.',
    'biscoito': 'Rico em farinha refinada e gorduras trans, oferecendo calorias vazias e pouca saciedade.',
    'salgadinho': 'Excesso de sódio e realçadores de sabor artificiais que sobrecarregam os rins.',
    'presunto': 'Processado: contém excesso de sódio e conservantes como nitritos.',
    'presunto-cotto': 'Processado: contém excesso de sódio e conservantes como nitritos.',
    'ham': 'Processado: contém excesso de sódio e conservantes como nitritos.',
    'ketchup': 'Ultraprocessado: rico em açúcar e xarope de milho.',
    'maionese': 'Ultraprocessado: rico em gorduras vegetais refinadas e aditivos.',
    'nutella': 'Ultraprocessado: excesso de açúcar e gordura vegetal hidrogenada.',
  };

  if (processed.containsKey(item)) {
    return MealItemAnalysis(name: item, type: 'processed', isWarning: true, detail: processed[item]!);
  }
  if (proteins.contains(item)) {
    return const MealItemAnalysis(name: 'Proteína', type: 'protein', isWarning: false, detail: 'Essencial para a construção muscular e controle da fome.');
  }
  if (carbos.contains(item)) {
    return const MealItemAnalysis(name: 'Carboidrato', type: 'carb', isWarning: false, detail: 'Fonte primária de energia para o cérebro e músculos.');
  }
  if (fibers.contains(item)) {
    return const MealItemAnalysis(name: 'Fibra', type: 'fiber', isWarning: false, detail: 'Essencial para a saúde intestinal e controle da glicemia.');
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
    title = 'Alerta de Processados';
    status = 'important';
    body = 'Sua refeição contém itens ultraprocessados. Esses alimentos geralmente possuem excesso de sódio, açúcares e gorduras artificiais que prejudicam o metabolismo.';
    improvement = 'Tente substituir o ${itemDetails.firstWhere((i) => i.isWarning).name} por uma opção natural ou caseira para reduzir a inflamação do corpo.';
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
