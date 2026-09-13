import 'package:flutter/material.dart';
import '../supabase_config.dart';
import '../theme.dart';
import '../models/meal_log.dart';
import 'meal_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  int _water = 0;
  bool _loading = true;
  List<MealLog> _meals = [];

  String get _name {
    final v = (supabase.auth.currentUser?.userMetadata?['full_name'] as String?)?.trim();
    return v?.isNotEmpty == true ? v! : 'Tudo bem por aí?';
  }
  String get _initial {
    final c = _name.trim();
    return c.isEmpty ? 'N' : c.substring(0, 1).toUpperCase();
  }

  @override
  void initState() { super.initState(); _loadMeals(); }

  Future<void> _loadMeals() async {
    try {
      final rows = await supabase.from('meals').select('id,meal_name,meal_type,created_at,calories,ingredients').eq('user_id', supabase.auth.currentUser!.id).order('created_at', ascending: false).limit(100);
      if (!mounted) return;
      setState(() { _meals = (rows as List).map((r) => MealLog.fromMap(Map<String, dynamic>.from(r))).toList(); _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _openMealEntry() async {
    final added = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const MealEntryPage()));
    if (added == true) await _loadMeals();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  bool _sameDay(DateTime a, DateTime b) => _dateKey(a) == _dateKey(b);
  List<MealLog> _mealsForDay(DateTime day) => _meals.where((m) => _sameDay(m.createdAt, day)).toList();
  List<MealLog> get _todayMeals => _mealsForDay(DateTime.now());
  num get _todayCalories => _todayMeals.fold<num>(0, (s, m) => s + (m.calories ?? 0));
  bool get _hasTodayCalories => _todayMeals.any((m) => m.calories != null);
  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final pages = [_dashboard(), _progress(), _profile()];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      floatingActionButton: _tab == 0 ? FloatingActionButton.extended(onPressed: _openMealEntry, icon: const Icon(Icons.add), label: const Text('Registrar')) : null,
      bottomNavigationBar: NavigationBar(height: 72, selectedIndex: _tab, onDestinationSelected: (i) => setState(() => _tab = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
        NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progresso'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
      ]),
    );
  }

  Widget _dashboard() {
    final meals = _todayMeals;
    final progress = _hasTodayCalories ? (_todayCalories / 2100).clamp(0.0, 1.0).toDouble() : 0.0;
    return RefreshIndicator(
      onRefresh: _loadMeals,
      child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(20, 22, 20, 120), children: [
        Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Olá, $_name 👋', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5), Text('Seu resumo de hoje', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))])), const SizedBox(width: 12), CircleAvatar(radius: 23, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(color: NutriTheme.green, fontWeight: FontWeight.w800)))]),
        const SizedBox(height: 20),
        NutrIACard(child: Column(children: [Row(children: [const NutrIABadge(text: 'Hoje', icon: Icons.today_outlined), const Spacer(), Flexible(child: Text('Meta 2.100 kcal', textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)))]), const SizedBox(height: 20), LayoutBuilder(builder: (context, c) { final size = c.maxWidth.clamp(150.0, 190.0).toDouble(); return SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [SizedBox.expand(child: CircularProgressIndicator(value: progress, strokeWidth: 16, strokeCap: StrokeCap.round, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, color: NutriTheme.green)), Padding(padding: const EdgeInsets.all(34), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_hasTodayCalories ? _todayCalories.toStringAsFixed(0) : '—', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark)), const SizedBox(height: 4), Text(_hasTodayCalories ? 'kcal' : 'pendentes', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey))]))])); }), const SizedBox(height: 20), Row(children: [_StatValue(label: 'Refeições', value: meals.length.toString()), const _StatValue(label: 'Meta', value: '2.100'), _StatValue(label: 'Água', value: '$_water ml')])])),
        const SizedBox(height: 24), Row(children: [Expanded(child: Text('Refeições de hoje', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), if (meals.isNotEmpty) TextButton(onPressed: () => setState(() => _tab = 1), child: const Text('Ver análise'))]),
        const SizedBox(height: 10),
        if (_loading) const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator())) else if (meals.isEmpty) _EmptyMealCard(onPressed: _openMealEntry) else ...meals.take(5).map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _MealTile(meal: m))),
        const SizedBox(height: 8),
        NutrIACard(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.water_drop_outlined, color: Colors.blue)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Hidratação', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('$_water ml registrados hoje', maxLines: 1, overflow: TextOverflow.ellipsis)])), const SizedBox(width: 8), OutlinedButton(onPressed: () => setState(() => _water += 250), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 44)), child: const Text('+250 ml'))]))
      ]),
    );
  }

  Widget _progress() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => DateTime(today.year, today.month, today.day - i));
    final current = _periodStats(days);
    final previousDays = List.generate(7, (i) => DateTime(today.year, today.month, today.day - 7 - i));
    final previous = _periodStats(previousDays);
    final hasData = current.meals > 0;

    return RefreshIndicator(
      onRefresh: _loadMeals,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 40), children: [
        Text('Como você se alimentou?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Uma leitura dos seus últimos 7 dias — dados primeiro, interpretação depois.'),
        const SizedBox(height: 18),
        NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const NutrIABadge(text: 'Últimos 7 dias', icon: Icons.auto_graph_outlined),
          const SizedBox(height: 16),
          if (!hasData) ...[
            Text('Ainda faltam registros', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Registre algumas refeições para o NutrIA começar a identificar padrões reais da sua alimentação.'),
          ] else ...[
            Row(children: [Expanded(child: Text('${current.score}/100', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark))), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('leitura do período', style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 3), Text(_scoreLabel(current.score), style: const TextStyle(fontWeight: FontWeight.w800))])]),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: current.score / 100, minHeight: 9, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, color: NutriTheme.green)),
            const SizedBox(height: 14),
            Text(_periodSummary(current), style: const TextStyle(fontSize: 15, height: 1.45)),
          ],
        ])),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: _ProgressMetric(title: 'Proteína', value: '${current.proteinMeals}/${current.meals}', subtitle: 'refeições', icon: Icons.fitness_center_outlined, progress: current.meals == 0 ? 0 : current.proteinMeals / current.meals)), const SizedBox(width: 10), Expanded(child: _ProgressMetric(title: 'Vegetais/fibras', value: '${current.fiberMeals}/${current.meals}', subtitle: 'refeições', icon: Icons.eco_outlined, progress: current.meals == 0 ? 0 : current.fiberMeals / current.meals))]),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _ProgressMetric(title: 'Variedade', value: '${current.uniqueMeals}', subtitle: 'combinações', icon: Icons.category_outlined, progress: (current.uniqueMeals / 10).clamp(0.0, 1.0).toDouble())), const SizedBox(width: 10), Expanded(child: _ProgressMetric(title: 'Processados', value: '${current.warningMeals}', subtitle: 'com alerta', icon: Icons.warning_amber_outlined, progress: current.meals == 0 ? 0 : (1 - current.warningMeals / current.meals).clamp(0.0, 1.0).toDouble(), inverse: true))]),
        const SizedBox(height: 22),
        Text('Dia a dia', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...days.map((day) => _dayCard(day, today)),
        const SizedBox(height: 10),
        if (hasData) _periodComparison(current, previous),
        const SizedBox(height: 14),
        if (hasData) _whatNutriaNoticed(current),
        const SizedBox(height: 14),
        _periodTotals(current),
      ]),
    );
  }

  _DayStats _dayStats(DateTime day) {
    final meals = _mealsForDay(day);
    var protein = 0, fiber = 0, warning = 0;
    final names = <String>{};
    for (final meal in meals) {
      names.add(meal.name.trim().toLowerCase());
      for (final ing in meal.ingredients ?? []) {
        if (ing is Map) {
          if (ing['type'] == 'protein') protein++;
          if (ing['type'] == 'fiber') fiber++;
          if (ing['is_warning'] == true) warning++;
        }
      }
      if (meal.ingredients?.any((i) => i is Map && i['type'] == 'protein') != true) {
        // Keep the metric conservative: only catalogued ingredient types count.
      }
    }
    return _DayStats(meals.length, protein, fiber, warning, names.length, meals.fold<num>(0, (s, m) => s + (m.calories ?? 0)));
  }

  _PeriodStats _periodStats(List<DateTime> days) {
    var meals = 0, protein = 0, fiber = 0, warning = 0, calories = 0.0;
    final names = <String>{};
    for (final day in days) {
      final s = _dayStats(day);
      meals += s.meals; protein += s.protein; fiber += s.fiber; warning += s.warning; calories += s.calories.toDouble(); names.addAll(_mealsForDay(day).map((m) => m.name.trim().toLowerCase()));
    }
    final proteinCoverage = meals == 0 ? 0.0 : (protein / meals).clamp(0.0, 1.0).toDouble();
    final fiberCoverage = meals == 0 ? 0.0 : (fiber / meals).clamp(0.0, 1.0).toDouble();
    final variety = (names.length / 10).clamp(0.0, 1.0).toDouble();
    final lowWarning = meals == 0 ? 1.0 : (1 - warning / meals).clamp(0.0, 1.0).toDouble();
    final score = meals == 0 ? 0 : (proteinCoverage * 30 + fiberCoverage * 30 + variety * 20 + lowWarning * 20).round();
    return _PeriodStats(meals, protein, fiber, warning, names.length, calories, score);
  }

  Widget _dayCard(DateTime day, DateTime today) {
    final s = _dayStats(day);
    final label = _sameDay(day, today) ? 'Hoje' : _formatDate(day);
    if (s.meals == 0) return Padding(padding: const EdgeInsets.only(bottom: 8), child: NutrIACard(padding: const EdgeInsets.all(14), child: Row(children: [const Icon(Icons.remove_circle_outline, color: Colors.grey), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), const Text('Nenhuma refeição registrada', style: TextStyle(color: Colors.grey))]))])));
    final insight = _dayInsight(s);
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: NutrIACard(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(13)), child: Icon(_sameDay(day, today) ? Icons.today_outlined : Icons.calendar_today_outlined, color: NutriTheme.green)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('${s.meals} ${s.meals == 1 ? 'refeição' : 'refeições'}', style: Theme.of(context).textTheme.bodySmall)])), Text(s.calories > 0 ? '${s.calories.toStringAsFixed(0)} kcal' : '—', style: const TextStyle(fontWeight: FontWeight.w800))]),
      const SizedBox(height: 11),
      Wrap(spacing: 6, runSpacing: 6, children: [_nutriTag(label: 'Prot ${s.protein}', active: s.protein > 0, color: Colors.orange), _nutriTag(label: 'Fibr ${s.fiber}', active: s.fiber > 0, color: Colors.green), _nutriTag(label: 'Var ${s.uniqueMeals}', active: s.uniqueMeals > 1, color: Colors.blue), if (s.warning > 0) _nutriTag(label: '${s.warning} alerta${s.warning == 1 ? '' : 's'}', active: true, color: Colors.red)]),
      const SizedBox(height: 10),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.lightbulb_outline, size: 18, color: NutriTheme.green), const SizedBox(width: 8), Expanded(child: Text(insight, style: const TextStyle(fontSize: 13, height: 1.35)))])
    ])));
  }

  String _dayInsight(_DayStats s) {
    if (s.warning > 0 && s.fiber == 0) return 'O dia teve alimentos com alerta e não registrou uma fonte de fibras nas refeições identificadas.';
    if (s.protein == s.meals && s.fiber > 0) return 'Boa presença de proteína e fibras nas refeições identificadas.';
    if (s.protein < s.meals && s.fiber > 0) return 'As refeições tiveram fibras, mas a presença de proteína apareceu em apenas parte delas.';
    if (s.protein == 0) return 'Não foi identificada proteína nas refeições catalogadas deste dia.';
    if (s.fiber == 0) return 'As refeições registradas não mostraram uma fonte de fibras pelo catálogo atual.';
    return 'O dia teve uma combinação variada de alimentos identificados.';
  }

  Widget _periodComparison(_PeriodStats current, _PeriodStats previous) {
    final proteinDelta = current.protein - previous.protein;
    final fiberDelta = current.fiber - previous.fiber;
    final warningDelta = current.warning - previous.warning;
    final direction = proteinDelta + fiberDelta - warningDelta;
    final text = direction > 0 ? 'Você avançou em alguns indicadores em relação aos 7 dias anteriores.' : direction < 0 ? 'Alguns indicadores ficaram abaixo dos 7 dias anteriores.' : 'Os indicadores ficaram parecidos com os 7 dias anteriores.';
    return NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'Comparação', icon: Icons.compare_arrows_outlined), const SizedBox(height: 14), Text('Esta semana × período anterior', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 10), _compareLine('Proteína', proteinDelta), _compareLine('Vegetais/fibras', fiberDelta), _compareLine('Alertas', warningDelta, inverse: true), const SizedBox(height: 10), Text(text, style: const TextStyle(fontSize: 13, height: 1.4))]));
  }

  Widget _compareLine(String label, int delta, {bool inverse = false}) {
    final positive = inverse ? delta <= 0 : delta >= 0;
    final sign = delta > 0 ? '+' : '';
    return Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [Expanded(child: Text(label)), Text('$sign$delta refeições', style: TextStyle(fontWeight: FontWeight.w800, color: positive ? NutriTheme.green : Colors.red))]));
  }

  Widget _whatNutriaNoticed(_PeriodStats s) {
    final observations = <String>[];
    if (s.meals >= 3 && s.uniqueMeals <= 2) observations.add('Você repetiu bastante as mesmas combinações.');
    if (s.meals > 0 && s.fiber / s.meals < .5) observations.add('Fibras apareceram em menos da metade das refeições identificadas.');
    if (s.meals > 0 && s.protein / s.meals < .5) observations.add('Proteína apareceu em menos da metade das refeições identificadas.');
    if (s.warning > 0) observations.add('${s.warning} refeição${s.warning == 1 ? '' : 'ões'} teve${s.warning == 1 ? '' : 'ram'} alimento${s.warning == 1 ? '' : 's'} com alerta.');
    if (observations.isEmpty) observations.add('O catálogo ainda não encontrou um padrão forte. Continue registrando para aumentar a qualidade da leitura.');
    final action = s.fiber / (s.meals == 0 ? 1 : s.meals) < .5 ? 'Próximo passo: tente incluir uma fonte de vegetais ou fruta em uma refeição que normalmente não tem.' : s.protein / (s.meals == 0 ? 1 : s.meals) < .5 ? 'Próximo passo: inclua uma fonte de proteína em mais uma refeição do dia.' : s.warning > 0 ? 'Próximo passo: quando possível, troque uma opção com alerta por uma alternativa menos processada.' : 'Próximo passo: mantenha a variedade e continue registrando as refeições.';
    return NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'O que o NutrIA percebeu', icon: Icons.psychology_outlined), const SizedBox(height: 14), ...observations.map((x) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('•  ', style: TextStyle(fontWeight: FontWeight.w900)), Expanded(child: Text(x, style: const TextStyle(height: 1.35)))]))), const Divider(height: 18), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.flag_outlined, size: 18, color: NutriTheme.green), const SizedBox(width: 8), Expanded(child: Text(action, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35)))])])));
  }

  Widget _periodTotals(_PeriodStats s) => NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'Resumo dos dados', icon: Icons.summarize_outlined), const SizedBox(height: 14), Text('${s.meals} refeições registradas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 10), Text('${s.protein} refeições com proteína • ${s.fiber} com fibras/vegetais • ${s.warning} com alerta • ${s.uniqueMeals} combinações diferentes', style: const TextStyle(height: 1.4)), if (s.calories > 0) ...[const SizedBox(height: 8), Text('${s.calories.toStringAsFixed(0)} kcal registradas no período', style: const TextStyle(fontWeight: FontWeight.w700))], const SizedBox(height: 8), const Text('Os indicadores usam apenas dados que o NutrIA conseguiu identificar; não são diagnóstico médico nem substituem orientação profissional.', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.35))]));

  String _periodSummary(_PeriodStats s) {
    final protein = s.protein / s.meals, fiber = s.fiber / s.meals;
    if (protein >= .7 && fiber >= .5 && s.warning / s.meals < .25) return 'Seu registro mostra boa presença de proteína e fibras, com poucos alertas entre as refeições identificadas.';
    if (fiber < .5 && protein >= .7) return 'A proteína apareceu com frequência, mas as fibras/vegetais ainda podem ganhar mais espaço nas refeições registradas.';
    if (protein < .5 && fiber >= .5) return 'As refeições identificadas tiveram boa presença de fibras, mas a proteína apareceu em menos da metade delas.';
    if (s.warning / s.meals >= .4) return 'Uma parcela relevante das refeições teve alimentos com alerta. Vale observar quais opções mais se repetem.';
    return 'Há sinais mistos no período. Quanto mais refeições você registrar, mais específica fica a leitura do seu padrão.';
  }

  String _scoreLabel(int score) => score >= 75 ? 'Bom equilíbrio' : score >= 50 ? 'Em construção' : 'Precisa de mais dados';

  Widget _nutriTag({required String label, required bool active, required Color color}) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: active ? color.withValues(alpha: .2) : Colors.grey.withValues(alpha: .1), borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? color : Colors.grey.withValues(alpha: .3))), child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: active ? color : Colors.grey)));

  Widget _profile() => ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 32), children: [Text('Seu perfil', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 20), NutrIACard(child: Column(children: [CircleAvatar(radius: 34, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(fontSize: 25, color: NutriTheme.green, fontWeight: FontWeight.w800))), const SizedBox(height: 12), Text(_name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(supabase.auth.currentUser?.email ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 20), OutlinedButton.icon(onPressed: () => supabase.auth.signOut(), icon: const Icon(Icons.logout), label: const Text('Sair da conta'))]))]);
}

class _DayStats {
  final int meals, protein, fiber, warning, uniqueMeals;
  final num calories;
  const _DayStats(this.meals, this.protein, this.fiber, this.warning, this.uniqueMeals, this.calories);
}
class _PeriodStats {
  final int meals, protein, fiber, warning, uniqueMeals, score;
  final double calories;
  const _PeriodStats(this.meals, this.protein, this.fiber, this.warning, this.uniqueMeals, this.calories, this.score);
}
class _StatValue extends StatelessWidget {
  final String label, value;
  const _StatValue({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: NutriTheme.greenDark)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: NutriTheme.green))])));
}
class _ProgressMetric extends StatelessWidget {
  final String title, value, subtitle; final IconData icon; final double progress; final bool inverse;
  const _ProgressMetric({required this.title, required this.value, required this.subtitle, required this.icon, required this.progress, this.inverse = false});
  @override
  Widget build(BuildContext context) => NutrIACard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 21, color: NutriTheme.green), const SizedBox(height: 10), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark)), Text(subtitle, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 9), ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, color: inverse && progress < .5 ? Colors.orange : NutriTheme.green))]));
}
class _MealTile extends StatelessWidget {
  final MealLog meal; const _MealTile({required this.meal});
  @override
  Widget build(BuildContext context) => NutrIACard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.restaurant_outlined, color: NutriTheme.green)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meal.type.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))])), const SizedBox(width: 8), SizedBox(width: 72, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(meal.calories == null ? '—' : '${meal.calories!.toStringAsFixed(0)} kcal', maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w800))))]));
}
class _EmptyMealCard extends StatelessWidget {
  final VoidCallback onPressed; const _EmptyMealCard({required this.onPressed});
  @override
  Widget build(BuildContext context) => NutrIACard(child: Column(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.restaurant_outlined, color: NutriTheme.green, size: 28)), const SizedBox(height: 14), Text('Nenhuma refeição registrada', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Quando você adicionar uma refeição, ela aparecerá aqui. Nada é criado automaticamente.', textAlign: TextAlign.center), const SizedBox(height: 16), OutlinedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add), label: const Text('Registrar primeira refeição'))]));
}
