import '../models/meal_feedback.dart';

/// Real-world meal combinations: the combination itself is the unit of analysis.
/// Ingredient order is normalized by meal_matching.dart, so equivalent orders resolve to the same feedback.
const mealFeedbackBatch08 = <String, MealFeedback>{
  'pão, manteiga e café': MealFeedback(
    'Café da manhã simples',
    'information',
    'O pão fornece principalmente carboidratos, a manteiga acrescenta gordura e o café contribui com líquido e cafeína. Como combinação, é uma refeição prática, mas com pouca variedade de grupos alimentares e pouca proteína.',
    'Para deixar esse café da manhã mais completo, combine o pão com ovo, queijo ou outra fonte de proteína e, quando possível, inclua uma fruta.',
  ),
  'pão, ovo e café com leite': MealFeedback(
    'Café da manhã com proteína',
    'positive',
    'O pão fornece energia, o ovo acrescenta proteína e o café com leite contribui com proteína e outros nutrientes do leite. É uma combinação mais completa do que pão e café isoladamente.',
    'Uma fruta pode aumentar a variedade e acrescentar fibras à refeição.',
  ),
  'arroz, feijão, bife, farofa e salada': MealFeedback(
    'Prato de restaurante brasileiro',
    'positive',
    'Essa combinação reúne arroz e feijão, uma fonte de proteína no bife, farofa e vegetais da salada. O conjunto oferece boa variedade, embora a quantidade de farofa e o preparo do bife possam aumentar a densidade energética da refeição.',
    'Mantenha a salada presente e ajuste principalmente as porções de farofa, frituras e molhos conforme o restante do dia.',
  ),
  'x-tudo, batata frita e refrigerante': MealFeedback(
    'Combo de lanchonete',
    'important',
    'O x-tudo concentra pão, carnes, queijo e outros recheios, enquanto a batata frita acrescenta gordura e o refrigerante fornece açúcar quando não é zero. É uma combinação bastante densa em energia e pode ter muito sódio.',
    'Se for uma refeição ocasional, o principal é observar a frequência. Para reduzir a carga da combinação, prefira água ou refrigerante sem açúcar e uma porção menor de fritas quando fizer sentido.',
  ),
  'açaí, banana, granola e leite condensado': MealFeedback(
    'Açaí com complementos',
    'attention',
    'A combinação do açaí com banana e granola acrescenta carboidratos e fibras, mas o leite condensado aumenta bastante a quantidade de açúcares adicionados. A composição final depende muito do tamanho da tigela e dos complementos.',
    'Para uma versão menos carregada, reduza o leite condensado e mantenha frutas e complementos menos açucarados.',
  ),
};
