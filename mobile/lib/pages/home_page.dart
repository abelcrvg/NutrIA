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
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final rows = await supabase
          .from('meals')
          .select('id,meal_name,meal_type,created_at,calories,ingredients')
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false)
          .limit(100);

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
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MealEntryPage()),
    );
    if (added == true) await _loadMeals();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  bool _sameDay(DateTime a, DateTime b) => _dateKey(a) == _dateKey(b);
  List<MealLog> get _todayMeals => _meals.where((m) => _sameDay(m.createdAt, DateTime.now())).toList();
  num get _todayCalories => _todayMeals.fold<num>(0, (s, m) => s + (m.calories ?? 0));
  bool get _hasTodayCalories => _todayMeals.any((m) => m.calories != null);
  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final pages = [_dashboard(), _progress(), _profile()];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _tab, children: pages),
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _openMealEntry,
              icon: const Icon(Icons.add),
              label: const Text('Registrar'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progresso'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _dashboard() {
    final meals = _todayMeals;
    final progress = _hasTodayCalories ? (_todayCalories / 2100).clamp(0.0, 1.0).toDouble() : 0.0;

    return RefreshIndicator(
      onRefresh: _loadMeals,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Olá, $_name 👋', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    Text('Seu resumo de hoje', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(radius: 23, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(color: NutriTheme.green, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 20),
          NutrIACard(
            child: Column(
              children: [
                Row(children: [const NutrIABadge(text: 'Hoje', icon: Icons.today_outlined), const Spacer(), Flexible(child: Text('Meta 2.100 kcal', textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)))]),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, c) {
                    final size = c.maxWidth.clamp(150.0, 190.0).toDouble();
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(child: CircularProgressIndicator(value: progress, strokeWidth: 16, strokeCap: StrokeCap.round, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, color: NutriTheme.green)),
                          Padding(
                            padding: const EdgeInsets.all(34),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_hasTodayCalories ? _todayCalories.toStringAsFixed(0) : '—', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.greenDark)),
                                const SizedBox(height: 4),
                                Text(_hasTodayCalories ? 'kcal' : 'pendentes', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(children: [_StatValue(label: 'Refeições', value: meals.length.toString()), const _StatValue(label: 'Meta', value: '2.100'), _StatValue(label: 'Água', value: '$_water ml')]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [Expanded(child: Text('Refeições de hoje', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), if (meals.isNotEmpty) TextButton(onPressed: () => setState(() => _tab = 1), child: const Text('Ver análise'))]),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()))
          else if (meals.isEmpty)
            _EmptyMealCard(onPressed: _openMealEntry)
          else
            ...meals.take(5).map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _MealTile(meal: m))),
          const SizedBox(height: 8),
          NutrIACard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.water_drop_outlined, color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Hidratação', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('$_water ml registrados hoje', maxLines: 1, overflow: TextOverflow.ellipsis)])),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => setState(() => _water += 250), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 44)), child: const Text('+250 ml')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => DateTime(today.year, today.month, today.day - i));

    return RefreshIndicator(
      onRefresh: _loadMeals,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        children: [
          Text('Análise dos dias', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Acompanhe seu equilíbrio nutricional diário.'),
          const SizedBox(height: 20),
          ...days.map((day) {
            final dm = _meals.where((m) => _sameDay(m.createdAt, day)).toList();
            final wc = dm.where((m) => m.calories != null).toList();
            final cal = wc.fold<num>(0, (s, m) => s + (m.calories ?? 0));
            final label = _sameDay(day, today) ? 'Hoje' : _formatDate(day);
            bool hasProtein = false, hasCarb = false, hasFiber = false, hasWarning = false;
            for (final meal in dm) {
              for (final ing in meal.ingredients ?? []) {
                if (ing is Map) {
                  if (ing['type'] == 'protein') hasProtein = true;
                  if (ing['type'] == 'carb') hasCarb = true;
                  if (ing['type'] == 'fiber') hasFiber = true;
                  if (ing['is_warning'] == true) hasWarning = true;
                }
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: NutrIACard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(13)), child: Icon(_sameDay(day, today) ? Icons.today_outlined : Icons.calendar_today_outlined, color: NutriTheme.green)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('${dm.length} ${dm.length == 1 ? 'refeição registrada' : 'refeições registradas'}', style: Theme.of(context).textTheme.bodySmall)])), Text(wc.isEmpty ? '—' : '${cal.toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.w800))]),
                    if (dm.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(spacing: 6, runSpacing: 6, children: [_nutriTag(label: 'Prot', active: hasProtein, color: Colors.orange), _nutriTag(label: 'Carb', active: hasCarb, color: Colors.blue), _nutriTag(label: 'Fibr', active: hasFiber, color: Colors.green), if (hasWarning) _nutriTag(label: 'Alerta', active: true, color: Colors.red, isWarning: true)]),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'Leitura do período', icon: Icons.insights_outlined), const SizedBox(height: 16), Text('${_meals.length} refeições registradas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('As calorias só aparecem quando houver um valor nutricional calculado. O NutrIA não inventa números para preencher o histórico.')]))
        ],
      ),
    );
  }

  Widget _nutriTag({required String label, required bool active, required Color color, bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: active ? color.withValues(alpha: .2) : Colors.grey.withValues(alpha: .1), borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? color : Colors.grey.withValues(alpha: .3))),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: active ? color : Colors.grey)),
    );
  }

  Widget _profile() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        children: [
          Text('Seu perfil', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          NutrIACard(
            child: Column(
              children: [
                CircleAvatar(radius: 34, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(fontSize: 25, color: NutriTheme.green, fontWeight: FontWeight.w800))),
                const SizedBox(height: 12),
                Text(_name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(supabase.auth.currentUser?.email ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                OutlinedButton.icon(onPressed: () => supabase.auth.signOut(), icon: const Icon(Icons.logout), label: const Text('Sair da conta')),
              ],
            ),
          ),
        ],
      );
}

class _StatValue extends StatelessWidget {
  final String label, value;
  const _StatValue({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: NutriTheme.greenDark)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: NutriTheme.green))])));
}

class _MealTile extends StatelessWidget {
  final MealLog meal;
  const _MealTile({required this.meal});
  @override
  Widget build(BuildContext context) => NutrIACard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.restaurant_outlined, color: NutriTheme.green)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meal.type.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))])), const SizedBox(width: 8), SizedBox(width: 72, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(meal.calories == null ? '—' : '${meal.calories!.toStringAsFixed(0)} kcal', maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w800))))]));
}

class _EmptyMealCard extends StatelessWidget {
  final VoidCallback onPressed;
  const _EmptyMealCard({required this.onPressed});
  @override
  Widget build(BuildContext context) => NutrIACard(child: Column(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.restaurant_outlined, color: NutriTheme.green, size: 28)), const SizedBox(height: 14), Text('Nenhuma refeição registrada', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Quando você adicionar uma refeição, ela aparecerá aqui. Nada é criado automaticamente.', textAlign: TextAlign.center), const SizedBox(height: 16), OutlinedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add), label: const Text('Registrar primeira refeição'))]));
}
