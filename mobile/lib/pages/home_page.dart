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
    final value = (supabase.auth.currentUser?.userMetadata?['full_name'] as String?)?.trim();
    return value?.isNotEmpty == true ? value! : 'Tudo bem por aí?';
  }

  String get _initial => _name.trim().isEmpty ? 'N' : _name.trim()[0].toUpperCase();

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final rows = await supabase.from('meals').select('id,meal_name,meal_type,created_at,calories,ingredients').eq('user_id', supabase.auth.currentUser!.id).order('created_at', ascending: false).limit(100);
      if (!mounted) return;
      setState(() {
        _meals = (rows as List).map((r) => MealLog.fromMap(Map<String, dynamic>.from(r))).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openMealEntry() async {
    final added = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const MealEntryPage()));
    if (added == true) await _loadMeals();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  bool _sameDay(DateTime a, DateTime b) => _dateKey(a) == _dateKey(b);
  List<MealLog> _mealsForDay(DateTime day) => _meals.where((m) => _sameDay(m.createdAt, day)).toList();
  List<MealLog> get _todayMeals => _mealsForDay(DateTime.now());
  num get _todayCalories => _todayMeals.fold<num>(0, (sum, m) => sum + (m.calories ?? 0));
  bool get _hasTodayCalories => _todayMeals.any((m) => m.calories != null);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: _tab, children: [_dashboard(), _progress(), _profile()])),
    floatingActionButton: _tab == 0 ? FloatingActionButton.extended(onPressed: _openMealEntry, icon: const Icon(Icons.add), label: const Text('Registrar')) : null,
    bottomNavigationBar: NavigationBar(selectedIndex: _tab, onDestinationSelected: (index) => setState(() => _tab = index), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
      NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progresso'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
    ]),
  );

  Widget _dashboard() {
    final meals = _todayMeals;
    final progress = _hasTodayCalories ? (_todayCalories / 2100).clamp(0.0, 1.0).toDouble() : 0.0;
    return RefreshIndicator(onRefresh: _loadMeals, child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(20, 22, 20, 120), children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Olá, $_name 👋', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5), Text('Seu resumo de hoje', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))])), CircleAvatar(radius: 23, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(color: NutriTheme.green, fontWeight: FontWeight.w800)))]),
      const SizedBox(height: 20),
      NutrIACard(child: Column(children: [Row(children: [const NutrIABadge(text: 'Hoje', icon: Icons.today_outlined), const Spacer(), const Text('Meta 2.100 kcal', style: TextStyle(fontSize: 12))]), const SizedBox(height: 20), SizedBox(width: 175, height: 175, child: Stack(alignment: Alignment.center, children: [SizedBox.expand(child: CircularProgressIndicator(value: progress, strokeWidth: 16, strokeCap: StrokeCap.round, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, color: NutriTheme.green)), Column(mainAxisSize: MainAxisSize.min, children: [Text(_hasTodayCalories ? _todayCalories.toStringAsFixed(0) : '—', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark)), Text(_hasTodayCalories ? 'kcal' : 'pendentes', style: Theme.of(context).textTheme.bodySmall)])])), const SizedBox(height: 20), Row(children: [_StatValue(label: 'Refeições', value: '${meals.length}'), _StatValue(label: 'Meta', value: '2.100'), _StatValue(label: 'Água', value: '$_water ml')])])),
      const SizedBox(height: 24),
      Row(children: [Expanded(child: Text('Refeições de hoje', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), if (meals.isNotEmpty) TextButton(onPressed: () => setState(() => _tab = 1), child: const Text('Ver análise'))]),
      const SizedBox(height: 10),
      if (_loading) const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())) else if (meals.isEmpty) _EmptyMealCard(onPressed: _openMealEntry) else ...meals.take(5).map((meal) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _MealTile(meal: meal))),
      NutrIACard(child: Row(children: [const Icon(Icons.water_drop_outlined, color: Colors.blue), const SizedBox(width: 12), Expanded(child: Text('$_water ml registrados hoje')), OutlinedButton(onPressed: () => setState(() => _water += 250), child: const Text('+250 ml'))])),
    ]));
  }

  Widget _progress() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => DateTime(today.year, today.month, today.day - i));
    final current = _periodStats(days);
    final previous = _periodStats(List.generate(7, (i) => DateTime(today.year, today.month, today.day - 7 - i)));
    final hasData = current.meals > 0;
    return RefreshIndicator(onRefresh: _loadMeals, child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 40), children: [
      Text('Como você se alimentou?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6), const Text('Uma leitura dos seus últimos 7 dias, baseada nas refeições que você registrou.'), const SizedBox(height: 18),
      NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'Últimos 7 dias', icon: Icons.auto_graph_outlined), const SizedBox(height: 16), if (!hasData) const Text('Registre algumas refeições para o NutrIA começar a identificar padrões reais.') else ...[
        Row(children: [Expanded(child: Text('${current.score}/100', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark))), Text(_scoreLabel(current.score), style: const TextStyle(fontWeight: FontWeight.w800))]), const SizedBox(height: 12), LinearProgressIndicator(value: current.score / 100, minHeight: 9), const SizedBox(height: 14), Text(_periodSummary(current))
      ]])),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: _ProgressMetric(title: 'Proteína', value: '${current.proteinMeals}/${current.meals}', subtitle: 'refeições', icon: Icons.fitness_center_outlined, progress: current.meals == 0 ? 0 : current.proteinMeals / current.meals)), const SizedBox(width: 10), Expanded(child: _ProgressMetric(title: 'Vegetais/fibras', value: '${current.fiberMeals}/${current.meals}', subtitle: 'refeições', icon: Icons.eco_outlined, progress: current.meals == 0 ? 0 : current.fiberMeals / current.meals))]),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: _ProgressMetric(title: 'Variedade', value: '${current.uniqueMeals}', subtitle: 'combinações', icon: Icons.category_outlined, progress: (current.uniqueMeals / 10).clamp(0.0, 1.0).toDouble())), const SizedBox(width: 10), Expanded(child: _ProgressMetric(title: 'Processados', value: '${current.warningMeals}', subtitle: 'com alerta', icon: Icons.warning_amber_outlined, progress: current.meals == 0 ? 0 : (1 - current.warningMeals / current.meals).clamp(0.0, 1.0).toDouble()))]),
      const SizedBox(height: 22), Text('Dia a dia', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 10), ...days.map((day) => _dayCard(day, today)),
      if (hasData) ...[const SizedBox(height: 8), _periodComparison(current, previous), const SizedBox(height: 14), _whatNutriaNoticed(current)], const SizedBox(height: 14), _periodTotals(current),
    ]));
  }

  _DayStats _dayStats(DateTime day) {
    final meals = _mealsForDay(day);
    var proteinMeals = 0, fiberMeals = 0, warningMeals = 0;
    final names = <String>{};
    for (final meal in meals) {
      names.add(meal.name.trim().toLowerCase());
      final ingredients = meal.ingredients ?? [];
      if (ingredients.any((i) => i is Map && i['type'] == 'protein')) proteinMeals++;
      if (ingredients.any((i) => i is Map && i['type'] == 'fiber')) fiberMeals++;
      if (ingredients.any((i) => i is Map && i['is_warning'] == true)) warningMeals++;
    }
    return _DayStats(meals.length, proteinMeals, fiberMeals, warningMeals, names.length, meals.fold<num>(0, (s, m) => s + (m.calories ?? 0)));
  }

  _PeriodStats _periodStats(List<DateTime> days) {
    var meals = 0, proteinMeals = 0, fiberMeals = 0, warningMeals = 0;
    var calories = 0.0;
    final names = <String>{};
    for (final day in days) {
      final stats = _dayStats(day);
      meals += stats.meals; proteinMeals += stats.proteinMeals; fiberMeals += stats.fiberMeals; warningMeals += stats.warningMeals; calories += stats.calories.toDouble();
      names.addAll(_mealsForDay(day).map((m) => m.name.trim().toLowerCase()));
    }
    final proteinCoverage = meals == 0 ? 0.0 : (proteinMeals / meals).clamp(0.0, 1.0).toDouble();
    final fiberCoverage = meals == 0 ? 0.0 : (fiberMeals / meals).clamp(0.0, 1.0).toDouble();
    final variety = (names.length / 10).clamp(0.0, 1.0).toDouble();
    final lowWarning = meals == 0 ? 1.0 : (1 - warningMeals / meals).clamp(0.0, 1.0).toDouble();
    final score = meals == 0 ? 0 : (proteinCoverage * 30 + fiberCoverage * 30 + variety * 20 + lowWarning * 20).round();
    return _PeriodStats(meals, proteinMeals, fiberMeals, warningMeals, names.length, calories, score);
  }

  Widget _dayCard(DateTime day, DateTime today) {
    final stats = _dayStats(day);
    final label = _sameDay(day, today) ? 'Hoje' : '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}';
    if (stats.meals == 0) return Padding(padding: const EdgeInsets.only(bottom: 8), child: NutrIACard(padding: const EdgeInsets.all(14), child: Row(children: [const Icon(Icons.remove_circle_outline, color: Colors.grey), const SizedBox(width: 12), Text('$label — nenhum registro')])));
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: NutrIACard(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), Text('${stats.calories.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.w800))]), const SizedBox(height: 8), Text('${stats.meals} refeições • ${stats.proteinMeals} com proteína • ${stats.fiberMeals} com fibras/vegetais • ${stats.warningMeals} com alerta'), const SizedBox(height: 7), Text(_dayInsight(stats), style: const TextStyle(fontSize: 13))])));
  }

  String _dayInsight(_DayStats stats) {
    if (stats.warningMeals > 0 && stats.fiberMeals == 0) return 'Houve alerta em pelo menos uma refeição e nenhuma refeição foi identificada com fibras/vegetais.';
    if (stats.proteinMeals == stats.meals && stats.fiberMeals > 0) return 'Boa presença de proteína e fibras nas refeições identificadas.';
    if (stats.proteinMeals == 0) return 'Nenhuma refeição foi identificada com proteína pelo catálogo atual.';
    if (stats.fiberMeals == 0) return 'Nenhuma refeição foi identificada com fibras/vegetais pelo catálogo atual.';
    return 'O dia teve presença parcial de proteína e fibras nas refeições identificadas.';
  }

  Widget _periodComparison(_PeriodStats current, _PeriodStats previous) => NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'Comparação', icon: Icons.compare_arrows_outlined), const SizedBox(height: 12), Text('Últimos 7 dias × período anterior', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 10), Text('Proteína: ${_delta(current.proteinMeals - previous.proteinMeals)}'), Text('Vegetais/fibras: ${_delta(current.fiberMeals - previous.fiberMeals)}'), Text('Alertas: ${_delta(current.warningMeals - previous.warningMeals)}')]));
  String _delta(int value) => '${value > 0 ? '+' : ''}$value refeições';

  Widget _whatNutriaNoticed(_PeriodStats stats) {
    final observations = <String>[];
    if (stats.meals >= 3 && stats.uniqueMeals <= 2) observations.add('Você repetiu bastante as mesmas combinações.');
    if (stats.fiberMeals < stats.meals / 2) observations.add('Fibras/vegetais apareceram em menos da metade das refeições identificadas.');
    if (stats.proteinMeals < stats.meals / 2) observations.add('Proteína apareceu em menos da metade das refeições identificadas.');
    if (stats.warningMeals > 0) observations.add('${stats.warningMeals} refeição(s) teve alerta.');
    if (observations.isEmpty) observations.add('Ainda não há um padrão forte o suficiente no catálogo. Continue registrando.');
    return NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'O que o NutrIA percebeu', icon: Icons.psychology_outlined), const SizedBox(height: 12), ...observations.map((text) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text('• $text')))]));
  }

  Widget _periodTotals(_PeriodStats stats) => NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'Resumo dos dados', icon: Icons.summarize_outlined), const SizedBox(height: 12), Text('${stats.meals} refeições registradas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 7), Text('${stats.proteinMeals} com proteína • ${stats.fiberMeals} com fibras/vegetais • ${stats.warningMeals} com alerta • ${stats.uniqueMeals} combinações diferentes'), if (stats.calories > 0) ...[const SizedBox(height: 7), Text('${stats.calories.toStringAsFixed(0)} kcal registradas')]]));

  String _periodSummary(_PeriodStats stats) {
    if (stats.meals == 0) return 'Ainda faltam dados para uma leitura confiável.';
    final protein = stats.proteinMeals / stats.meals;
    final fiber = stats.fiberMeals / stats.meals;
    if (protein >= .7 && fiber >= .5 && stats.warningMeals / stats.meals < .25) return 'Boa presença de proteína e fibras, com poucos alertas nas refeições identificadas.';
    if (protein >= .7 && fiber < .5) return 'A proteína apareceu com frequência, mas fibras e vegetais ainda podem aparecer mais.';
    if (protein < .5 && fiber >= .5) return 'As fibras apareceram com frequência, mas a proteína foi identificada em menos da metade das refeições.';
    if (stats.warningMeals / stats.meals >= .4) return 'Uma parcela relevante das refeições teve alimentos com alerta.';
    return 'Há sinais mistos. Mais registros tornam a leitura do seu padrão mais específica.';
  }

  String _scoreLabel(int score) => score >= 75 ? 'Bom equilíbrio' : score >= 50 ? 'Em construção' : 'Poucos dados';

  Widget _profile() => ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 32), children: [Text('Seu perfil', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 20), NutrIACard(child: Column(children: [CircleAvatar(radius: 34, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(fontSize: 25, color: NutriTheme.green, fontWeight: FontWeight.w800))), const SizedBox(height: 12), Text(_name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(supabase.auth.currentUser?.email ?? '', textAlign: TextAlign.center), const SizedBox(height: 18), OutlinedButton.icon(onPressed: () => supabase.auth.signOut(), icon: const Icon(Icons.logout), label: const Text('Sair da conta'))]))]);
}

class _DayStats {
  final int meals, proteinMeals, fiberMeals, warningMeals, uniqueMeals;
  final num calories;
  const _DayStats(this.meals, this.proteinMeals, this.fiberMeals, this.warningMeals, this.uniqueMeals, this.calories);
}

class _PeriodStats {
  final int meals, proteinMeals, fiberMeals, warningMeals, uniqueMeals, score;
  final double calories;
  const _PeriodStats(this.meals, this.proteinMeals, this.fiberMeals, this.warningMeals, this.uniqueMeals, this.calories, this.score);
}

class _StatValue extends StatelessWidget {
  final String label, value;
  const _StatValue({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6), child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: NutriTheme.greenDark)), const SizedBox(height: 4), Text(label, style: Theme.of(context).textTheme.bodySmall)])));
}

class _ProgressMetric extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final double progress;
  const _ProgressMetric({required this.title, required this.value, required this.subtitle, required this.icon, required this.progress});
  @override
  Widget build(BuildContext context) => NutrIACard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 21, color: NutriTheme.green), const SizedBox(height: 8), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark)), Text(subtitle, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 8), LinearProgressIndicator(value: progress)]));
}

class _MealTile extends StatelessWidget {
  final MealLog meal;
  const _MealTile({required this.meal});
  @override
  Widget build(BuildContext context) => NutrIACard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), child: Row(children: [const Icon(Icons.restaurant_outlined, color: NutriTheme.green), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meal.type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))])), Text(meal.calories == null ? '—' : '${meal.calories!.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.w800))]));
}

class _EmptyMealCard extends StatelessWidget {
  final VoidCallback onPressed;
  const _EmptyMealCard({required this.onPressed});
  @override
  Widget build(BuildContext context) => NutrIACard(child: Column(children: [const Icon(Icons.restaurant_outlined, color: NutriTheme.green, size: 32), const SizedBox(height: 12), const Text('Nenhuma refeição registrada', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Registre uma refeição para começar.'), const SizedBox(height: 14), OutlinedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add), label: const Text('Registrar primeira refeição'))]));
}
