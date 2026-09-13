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
  bool _loading = true;
  bool _waterLoading = true;
  List<MealLog> _meals = [];
  List<Map<String, dynamic>> _waterLogs = [];
  static const int _waterGoal = 2000;

  String get _name {
    final value = (supabase.auth.currentUser?.userMetadata?['full_name'] as String?)?.trim();
    return value?.isNotEmpty == true ? value! : 'Tudo bem por aí?';
  }
  String get _initial => _name.trim().isEmpty ? 'N' : _name.trim()[0].toUpperCase();

  @override
  void initState() { super.initState(); _loadAll(); }

  Future<void> _loadAll() async {
    await Future.wait([_loadMeals(), _loadWater()]);
  }

  Future<void> _loadMeals() async {
    try {
      final rows = await supabase.from('meals').select('id,meal_name,meal_type,created_at,calories,ingredients').eq('user_id', supabase.auth.currentUser!.id).order('created_at', ascending: false).limit(100);
      if (!mounted) return;
      setState(() { _meals = (rows as List).map((r) => MealLog.fromMap(Map<String, dynamic>.from(r))).toList(); _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  DateTime _startOfTodayUtc() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toUtc();
  }

  Future<void> _loadWater() async {
    try {
      final start = _startOfTodayUtc();
      final end = start.add(const Duration(days: 1));
      final rows = await supabase.from('water_logs').select('id,amount_ml,consumed_at').eq('user_id', supabase.auth.currentUser!.id).gte('consumed_at', start.toIso8601String()).lt('consumed_at', end.toIso8601String()).order('consumed_at', ascending: false);
      if (!mounted) return;
      setState(() { _waterLogs = (rows as List).map((r) => Map<String, dynamic>.from(r)).toList(); _waterLoading = false; });
    } catch (_) { if (mounted) setState(() => _waterLoading = false); }
  }

  int get _water => _waterLogs.fold(0, (sum, row) => sum + ((row['amount_ml'] as num?)?.toInt() ?? 0));

  Future<void> _addWater(int amount) async {
    final user = supabase.auth.currentUser;
    if (user == null || _waterLoading) return;
    try {
      await supabase.from('water_logs').insert({'user_id': user.id, 'amount_ml': amount, 'consumed_at': DateTime.now().toUtc().toIso8601String()});
      await _loadWater();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível registrar a água: $error')));
    }
  }

  Future<void> _removeLastWater() async {
    if (_waterLogs.isEmpty) return;
    final id = _waterLogs.first['id'];
    try { await supabase.from('water_logs').delete().eq('id', id).eq('user_id', supabase.auth.currentUser!.id); await _loadWater(); } catch (_) {}
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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: _tab, children: [_dashboard(), _progress(), _profile()])),
    floatingActionButton: _tab == 0 ? FloatingActionButton.extended(onPressed: _openMealEntry, icon: const Icon(Icons.add), label: const Text('Registrar')) : null,
    bottomNavigationBar: NavigationBar(selectedIndex: _tab, onDestinationSelected: (i) => setState(() => _tab = i), destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
      NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progresso'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
    ]),
  );

  Widget _dashboard() {
    final meals = _todayMeals;
    final calorieProgress = (_todayCalories / 2100).clamp(0.0, 1.0).toDouble();
    final waterProgress = (_water / _waterGoal).clamp(0.0, 1.0).toDouble();
    return RefreshIndicator(onRefresh: _loadAll, child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(20, 22, 20, 120), children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Olá, $_name 👋', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 5), Text('Seu resumo de hoje', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))])), CircleAvatar(radius: 23, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(color: NutriTheme.green, fontWeight: FontWeight.w800)))]),
      const SizedBox(height: 20),
      NutrIACard(child: Column(children: [Row(children: [const NutrIABadge(text: 'Hoje', icon: Icons.today_outlined), const Spacer(), const Text('Meta 2.100 kcal', style: TextStyle(fontSize: 12))]), const SizedBox(height: 20), SizedBox(width: 175, height: 175, child: Stack(alignment: Alignment.center, children: [SizedBox.expand(child: CircularProgressIndicator(value: calorieProgress, strokeWidth: 16, strokeCap: StrokeCap.round, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, color: NutriTheme.green)), Column(mainAxisSize: MainAxisSize.min, children: [Text(_todayCalories > 0 ? _todayCalories.toStringAsFixed(0) : '—', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark)), Text(_todayCalories > 0 ? 'kcal' : 'pendentes', style: Theme.of(context).textTheme.bodySmall)])])), const SizedBox(height: 20), Row(children: [_StatValue(label: 'Refeições', value: '${meals.length}'), _StatValue(label: 'Meta', value: '2.100'), _StatValue(label: 'Água', value: '$_water ml')])])),
      const SizedBox(height: 24),
      Row(children: [Expanded(child: Text('Refeições de hoje', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), if (meals.isNotEmpty) TextButton(onPressed: () => setState(() => _tab = 1), child: const Text('Ver análise'))]),
      const SizedBox(height: 10),
      if (_loading) const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())) else if (meals.isEmpty) _EmptyMealCard(onPressed: _openMealEntry) else ...meals.take(8).map((meal) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _MealTile(meal: meal))),
      const SizedBox(height: 8),
      NutrIACard(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.water_drop_outlined, color: Colors.blue)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Hidratação', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(_waterLoading ? 'Carregando...' : '$_water ml de $_waterGoal ml hoje', style: Theme.of(context).textTheme.bodySmall)])), IconButton(onPressed: _waterLogs.isEmpty ? null : _removeLastWater, tooltip: 'Desfazer último registro', icon: const Icon(Icons.undo))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: waterProgress, minHeight: 9, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, color: Colors.blue)), const SizedBox(height: 12), Row(children: [Expanded(child: OutlinedButton(onPressed: () => _addWater(200), child: const Text('+200 ml'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () => _addWater(250), child: const Text('+250 ml'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () => _addWater(500), child: const Text('+500 ml')))])]))
    ]));
  }

  Widget _progress() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => DateTime(today.year, today.month, today.day - i));
    final meals = days.expand(_mealsForDay).toList();
    final protein = meals.where((m) => (m.ingredients ?? []).any((i) => i is Map && i['type'] == 'protein')).length;
    final fiber = meals.where((m) => (m.ingredients ?? []).any((i) => i is Map && i['type'] == 'fiber')).length;
    final alerts = meals.where((m) => (m.ingredients ?? []).any((i) => i is Map && i['is_warning'] == true)).length;
    final score = meals.isEmpty ? 0 : ((protein / meals.length) * 35 + (fiber / meals.length) * 35 + (1 - alerts / meals.length) * 30).round();
    return RefreshIndicator(onRefresh: _loadAll, child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 40), children: [Text('Como você se alimentou?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Uma leitura dos seus últimos 7 dias, baseada nos registros reais do diário.'), const SizedBox(height: 18), NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'Últimos 7 dias', icon: Icons.auto_graph_outlined), const SizedBox(height: 14), Text(meals.isEmpty ? 'Ainda faltam registros' : '$score/100', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark)), const SizedBox(height: 8), if (meals.isEmpty) const Text('Registre refeições para o NutrIA começar a identificar seus padrões.') else Text('$protein refeições com proteína • $fiber com fibras/vegetais • $alerts com alerta', style: const TextStyle(height: 1.4))])), const SizedBox(height: 18), Text('Dia a dia', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 10), ...days.map((day) { final dayMeals = _mealsForDay(day); final label = _sameDay(day, today) ? 'Hoje' : '${day.day.toString().padLeft(2,'0')}/${day.month.toString().padLeft(2,'0')}'; return Padding(padding: const EdgeInsets.only(bottom: 8), child: NutrIACard(padding: const EdgeInsets.all(14), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(dayMeals.isEmpty ? 'Nenhuma refeição registrada' : '${dayMeals.length} refeição(s) • ${dayMeals.fold<num>(0,(s,m)=>s+(m.calories??0)).toStringAsFixed(0)} kcal')]))]))); })]));
  }

  Widget _profile() => ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 32), children: [Text('Seu perfil', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 20), NutrIACard(child: Column(children: [CircleAvatar(radius: 34, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(fontSize: 25, color: NutriTheme.green, fontWeight: FontWeight.w800))), const SizedBox(height: 12), Text(_name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(supabase.auth.currentUser?.email ?? '', textAlign: TextAlign.center), const SizedBox(height: 18), OutlinedButton.icon(onPressed: () => supabase.auth.signOut(), icon: const Icon(Icons.logout), label: const Text('Sair da conta'))]))]);
}

class _StatValue extends StatelessWidget { final String label, value; const _StatValue({required this.label, required this.value}); @override Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6), child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: NutriTheme.greenDark)), const SizedBox(height: 4), Text(label, style: Theme.of(context).textTheme.bodySmall)]))); }
class _MealTile extends StatelessWidget { final MealLog meal; const _MealTile({required this.meal}); @override Widget build(BuildContext context) => NutrIACard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), child: Row(children: [const Icon(Icons.restaurant_outlined, color: NutriTheme.green), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meal.type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))])), Text(meal.calories == null ? '—' : '${meal.calories!.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.w800))])); }
class _EmptyMealCard extends StatelessWidget { final VoidCallback onPressed; const _EmptyMealCard({required this.onPressed}); @override Widget build(BuildContext context) => NutrIACard(child: Column(children: [const Icon(Icons.restaurant_outlined, color: NutriTheme.green, size: 32), const SizedBox(height: 12), const Text('Nenhuma refeição registrada', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Registre uma refeição para começar.'), const SizedBox(height: 14), OutlinedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add), label: const Text('Registrar primeira refeição'))])); }
