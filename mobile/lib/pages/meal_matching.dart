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

/// Heuristic analysis for meals not in the catalog
MealFeedback _analyzeByComposition(String input) {
  final words = normalizeMealText(input).split(' ').where((w)=>w.isNotEmpty).toSet();

  const carbos = {'arroz', 'macarrao', 'batata', 'pao', 'tapioca', 'cuscuz', 'farofa', 'mandioca', 'milho', 'aveia', 'massa'};
  const proteins = {'carne', 'frango', 'peixe', 'ovo', 'feijao', 'lentilha', 'grao-de-bico', 'queijo', 'leite', 'soja', 'tofu'};
  const fibers = {'salada', 'legumes', 'verduras', 'brocolis', 'alface', 'cenoura', 'abobrinha', 'tomate', 'fruta', 'banana', 'maca', 'laranja', 'espinafre'};

  // Alimentos ultraprocessados ou "não confiáveis"
  const processed = {
    'miojo': 'Este alimento é ultraprocessado, rico em sódio e aditivos químicos, não sendo uma fonte confiável de nutrição.',
    'salsicha': 'Alimento com alto índice de processamento e conservantes, deve ser evitado.',
    'nugget': 'Produto ultraprocessado com baixo valor nutricional e alta quantidade de gorduras saturadas.',
    'refrigerante': 'Contém excesso de açúcares e corantes, prejudicando a saúde metabólica.',
    'biscoito': 'Geralmente rico em farinha refinada e gorduras trans, oferecendo pouca nutrição real.',
    'salgadinho': 'Produto ultraprocessado com excesso de sódio e realçadores de sabor artificiais.',
  };

  // 1. Priority: Check for processed foods first
  for (var item in processed) {
    if (words.contains(item.key)) {
      return MealFeedback(
        'Alerta de Ultraprocessado',
        'important',
        item.value,
        'Substitua este item por comida de verdade (alimentos in natura) para melhorar sua saúde.'
      );
    }
  }

  bool hasCarb = words.any((w) => carbos.contains(w));
  bool hasProtein = words.any((w) => proteins.contains(w));
  bool hasFiber = words.any((w) => fibers.contains(w));

  if (hasCarb && hasProtein && hasFiber) {
    return const MealFeedback(
      'Refeição Equilibrada',
      'positive',
      'Sua refeição contém carboidratos para energia, proteínas para os músculos e fibras para a saúde digestiva.',
      'Continue variando as cores dos vegetais e as fontes de proteína.'
    );
  } else if (!hasProtein) {
    return const MealFeedback(
      'Falta Proteína',
      'attention',
      'Sua refeição tem energia, mas falta uma fonte de proteína (como ovo, carne ou leguminosas) para garantir a saciedade e manutenção muscular.',
      'Tente adicionar um ovo, frango ou feijão para equilibrar o prato.'
    );
  } else if (!hasFiber) {
    return const MealFeedback(
      'Faltam Fibras',
      'attention',
      'Você tem a base de energia e proteína, mas faltam vegetais ou frutas. Fibras são essenciais para o funcionamento do intestino e controle da glicemia.',
      'Adicione uma porção de salada, legumes ou uma fruta após a refeição.'
    );
  } else if (!hasCarb) {
    return const MealFeedback(
      'Pouco Carboidrato',
      'information',
      'Sua refeição é rica em nutrientes e proteínas, mas tem poucos carboidratos. Dependendo do seu objetivo, você pode sentir fome mais rápido.',
      'Se sentir cansaço, adicione uma fonte de carbo complexo como arroz integral ou batata doce.'
    );
  } else {
    return const MealFeedback(
      'Análise Incompleta',
      'information',
      'Não conseguimos identificar grupos nutricionais claros nesta combinação.',
      'Tente descrever a refeição com mais detalhes (ex: "frango com salada").'
    );
  }
}

MealFeedback? findMealFeedbackSmart(String input) {
  final catalog = FeedbackService().allFeedbacks;

  // 1. Try exact/close match in catalog
  // We normalize both input and catalog keys for a fair comparison
  final normalizedInput = normalizeMealText(input);

  // Check for exact matches in the fetched catalog
  if (catalog.containsKey(normalizedInput)) {
    return catalog[normalizedInput];
  }

  // Partial matching: check if the input contains a catalog entry
  MealFeedback? best;
  var bestScore = 0.0;

  for (final entry in catalog.entries) {
    final candidate = entry.key.split(' ').toSet();
    final inputWords = normalizedInput.split(' ').where((w)=>w.isNotEmpty).toSet();

    if (candidate.isEmpty || !candidate.every(inputWords.contains)) continue;
    final score = candidate.length / inputWords.length;
    if (score > bestScore) {
      bestScore = score;
      best = entry.value;
    }
  }

  if (best != null && bestScore > 0.5) return best;

  // 2. Fallback to Heuristic Analysis
  return _analyzeByComposition(input);
}

IconData feedbackIcon(String status) {
  switch (status) {
    case 'positive': return Icons.check_circle_outline;
    case 'attention': return Icons.warning_amber_outlined;
    case 'important': return Icons.error_outline;
    default: return Icons.info_outline;
  }
}
