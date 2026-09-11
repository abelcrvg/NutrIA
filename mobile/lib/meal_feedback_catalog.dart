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
  'arroz, feijão, ovo e salada': MealFeedback('Refeição bem distribuída', 'positive', 'O arroz fornece carboidratos, o feijão acrescenta fibras e nutrientes, o ovo fornece proteína e a salada amplia a variedade de vegetais.', 'Varie as verduras e legumes e ajuste as porções de acordo com sua rotina alimentar.'),
  'macarrão, carne e salada': MealFeedback('Boa combinação', 'positive', 'O macarrão é uma fonte de carboidratos, a carne contribui com proteína e a salada adiciona vegetais e fibras.', 'Priorize preparações com menos óleo e varie os vegetais ao longo da semana.'),
  'hambúrguer e batata frita': MealFeedback('Atenção ao conjunto', 'attention', 'O hambúrguer fornece proteína, mas pode concentrar gordura e sódio. A batata frita aumenta a densidade energética por causa da fritura.', 'Reduza a frequência ou a porção da fritura e acrescente vegetais à refeição.'),
  'açaí com banana': MealFeedback('Pode ser uma boa opção', 'information', 'A banana contribui com carboidratos, fibras e micronutrientes, enquanto o açaí pode fazer parte de um lanche. O preparo e os acompanhamentos mudam bastante o perfil final.', 'Observe a quantidade de açúcar e coberturas adicionadas e considere combinar com uma fonte de proteína quando fizer sentido.'),
  'iogurte, banana e aveia': MealFeedback('Boa combinação', 'positive', 'O iogurte fornece proteína, a banana contribui com carboidratos e fibras, e a aveia acrescenta fibras e ajuda a tornar a refeição mais completa.', 'Prefira iogurte natural quando possível e varie as frutas e sementes ao longo da semana.'),
  'arroz integral, frango e salada': MealFeedback('Refeição equilibrada', 'positive', 'O arroz integral fornece carboidratos e mais fibras que versões refinadas, o frango acrescenta proteína e a salada amplia a presença de vegetais.', 'Varie legumes e verduras e ajuste as porções ao restante do dia.'),
  'arroz integral, feijão e frango': MealFeedback('Boa base para a refeição', 'positive', 'O arroz integral e o feijão combinam fontes de carboidratos e fibras, enquanto o frango acrescenta proteína. É uma base versátil para uma refeição completa.', 'Acrescente verduras ou legumes para aumentar a variedade de vegetais.'),
  'macarrão, carne, ovo e salada': MealFeedback('Refeição completa', 'positive', 'O macarrão fornece carboidratos, carne e ovo acrescentam proteínas, e a salada contribui com vegetais e fibras. A combinação reúne vários grupos alimentares.', 'Observe o tamanho das porções e a quantidade de óleo e molhos usados no preparo.'),
  'açaí, banana e iogurte natural': MealFeedback('Boa combinação para um lanche', 'positive', 'A banana fornece carboidratos e fibras, o iogurte natural acrescenta proteína e o açaí contribui com energia. Os acompanhamentos podem alterar bastante o resultado.', 'Prefira preparações com menos açúcar adicionado e observe as porções dos acompanhamentos.'),
  'miojo com ovo': MealFeedback('Atenção ao conjunto', 'attention', 'O ovo acrescenta proteína ao macarrão instantâneo, mas o miojo costuma concentrar sódio e oferece pouca variedade de vegetais e fibras.', 'Use menos do tempero pronto, acrescente vegetais e alterne com outras fontes de carboidratos e proteínas.'),
  'omelete com salada': MealFeedback('Boa combinação', 'positive', 'A omelete fornece proteína e a salada contribui com vegetais e fibras. É uma combinação simples que pode ser adaptada com diferentes legumes.', 'Inclua legumes na omelete ou varie os vegetais da salada.'),
  'arroz com feijão e ovo': MealFeedback('Boa combinação', 'positive', 'O arroz fornece carboidratos, o feijão contribui com fibras e nutrientes, e o ovo acrescenta proteína.', 'Acrescente vegetais e varie as fontes de proteína ao longo da semana.'),
  'tapioca com ovo e banana': MealFeedback('Pode ficar mais completa', 'positive', 'A tapioca e a banana fornecem carboidratos, enquanto o ovo acrescenta proteína. A fruta também contribui com fibras e micronutrientes.', 'Inclua vegetais em outra refeição e observe as porções quando combinar várias fontes de carboidratos.'),
  'arroz, feijão, carne, salada e farofa': MealFeedback('Refeição variada, mas densa', 'information', 'A combinação reúne carboidratos do arroz e da farofa, proteína da carne, fibras do feijão e vegetais da salada. A farofa acrescenta mais uma fonte de carboidrato e sua preparação pode aumentar gordura e sódio.', 'Ajuste a porção de farofa ao restante do prato e mantenha uma boa presença de feijão, verduras e legumes.'),
  'cuscuz com ovo': MealFeedback('Boa base para o café da manhã', 'positive', 'O cuscuz fornece principalmente carboidratos e o ovo acrescenta proteína, formando uma combinação simples e versátil.', 'Acrescente uma fruta ou vegetais em outras refeições e varie as fontes de proteína ao longo do dia.'),
  'cuscuz com frango e salada': MealFeedback('Refeição bem composta', 'positive', 'O cuscuz fornece carboidratos, o frango acrescenta proteína e a salada contribui com vegetais e fibras. A combinação reúne diferentes grupos alimentares.', 'Varie os vegetais e observe a quantidade de óleo, molhos e acompanhamentos usados no preparo.'),
  'pão de queijo com café': MealFeedback('Pode ficar mais completa', 'information', 'O pão de queijo fornece carboidratos e gordura, enquanto o café pode acompanhar a refeição. Sozinha, a combinação tende a oferecer pouca fibra e uma quantidade limitada de proteína.', 'Combine com uma fruta e, quando fizer sentido, com uma fonte de proteína como iogurte ou ovo.'),
  'vitamina de banana com aveia': MealFeedback('Boa opção para um lanche', 'positive', 'A banana contribui com carboidratos e fibras, e a aveia acrescenta fibras. O perfil final depende da base usada e dos ingredientes adicionados.', 'Use uma base com pouco açúcar adicionado e considere incluir uma fonte de proteína para deixar o lanche mais completo.'),
  'arroz, feijão, carne e ovo': MealFeedback('Boa combinação de base', 'positive', 'O arroz e o feijão formam uma base tradicional com carboidratos e fibras, enquanto carne e ovo acrescentam proteínas. A preparação e as porções influenciam o perfil final.', 'Inclua verduras ou legumes e observe a quantidade de óleo usada no preparo.'),
  'arroz, frango e ovo': MealFeedback('Boa combinação de proteínas', 'positive', 'O arroz fornece carboidratos e frango e ovo acrescentam proteínas. A combinação pode ser bastante prática, mas ainda se beneficia da presença de vegetais.', 'Acrescente legumes ou salada e varie as fontes de proteína ao longo da semana.'),
  'macarrão, carne e ovo': MealFeedback('Refeição rica em proteínas', 'information', 'O macarrão fornece carboidratos e carne e ovo concentram proteínas. Sem vegetais, a combinação pode ter pouca fibra e variedade alimentar.', 'Acrescente verduras ou legumes e observe a quantidade de óleo e molho utilizada.'),
  'açaí com banana e aveia': MealFeedback('Lanche com fibras', 'positive', 'A banana e a aveia contribuem com fibras, enquanto o açaí fornece energia. O resultado varia conforme a preparação do açaí e os acompanhamentos.', 'Prefira versões com menos açúcar adicionado e considere uma fonte de proteína quando fizer sentido.'),
  'pão francês com ovo e café': MealFeedback('Café da manhã simples', 'information', 'O pão fornece carboidratos, o ovo acrescenta proteína e o café acompanha a refeição. A combinação pode ficar limitada em fibras dependendo dos acompanhamentos.', 'Acrescente uma fruta e, se possível, varie os tipos de pão e fontes de fibras ao longo da semana.'),
  'arroz, feijão, frango e ovo': MealFeedback('Refeição rica em proteína', 'positive', 'Arroz e feijão formam uma base com carboidratos e fibras, enquanto frango e ovo reforçam a oferta de proteína. A combinação é variada, mas ainda pode ganhar mais vegetais.', 'Acrescente salada ou legumes e ajuste as porções de frango e ovo conforme o restante da refeição.'),
  'macarrão com frango e salada': MealFeedback('Boa refeição completa', 'positive', 'O macarrão fornece carboidratos, o frango acrescenta proteína e a salada traz vegetais e fibras. A presença dos três componentes deixa a refeição mais variada.', 'Varie os vegetais e observe a quantidade de óleo, molho e queijo adicionados.'),
  'tapioca com ovo e banana': MealFeedback('Combinação prática', 'positive', 'A tapioca e a banana concentram carboidratos, enquanto o ovo acrescenta proteína. A banana também contribui com fibras e micronutrientes.', 'Observe a porção de tapioca e considere incluir vegetais em outra refeição do dia.'),
  'pizza de queijo com salada': MealFeedback('Pode ficar mais variada', 'information', 'A pizza de queijo fornece carboidratos, gordura e proteína, enquanto a salada acrescenta vegetais e fibras. A combinação ganha variedade com a presença dos vegetais.', 'Varie os vegetais e observe a quantidade de queijo, massa e molhos utilizados.'),
  'pão francês com ovo e banana': MealFeedback('Café da manhã mais completo', 'positive', 'O pão fornece carboidratos, o ovo acrescenta proteína e a banana contribui com fibras e micronutrientes. A combinação reúne diferentes grupos alimentares.', 'Varie as frutas e considere versões com mais fibras para o pão quando possível.'),
};

MealFeedback? findMealFeedback(String input) {
  final normalized = normalizeMealText(input);
  MealFeedback? best;
  var bestScore = 0.0;
  final words = normalized.split(' ').where((word) => word.isNotEmpty).toSet();
  if (words.isEmpty) return null;
  for (final entry in mealFeedbacks.entries) {
    final candidate = normalizeMealText(entry.key).split(' ').where((word) => word.isNotEmpty).toSet();
    if (candidate.isEmpty || !candidate.every(words.contains)) continue;
    final score = candidate.length / words.length;
    if (score > bestScore) { bestScore = score; best = entry.value; }
  }
  return best;
}

String normalizeMealText(String input) {
  var value = input.toLowerCase().trim();
  const replacements = {'á':'a','à':'a','ã':'a','â':'a','ä':'a','é':'e','ê':'e','ë':'e','í':'i','ï':'i','ó':'o','ô':'o','õ':'o','ö':'o','ú':'u','ü':'u','ç':'c'};
  replacements.forEach((from, to) => value = value.replaceAll(from, to));
  value = value.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  const aliases = {'refri':'refrigerante','burguer':'hamburguer'};
  return value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).map((word) => aliases[word] ?? word).join(' ');
}

IconData feedbackIcon(String status) {
  switch (status) {
    case 'positive': return Icons.check_circle_outline;
    case 'attention': return Icons.warning_amber_rounded;
    case 'important': return Icons.error_outline;
    default: return Icons.info_outline;
  }
}
