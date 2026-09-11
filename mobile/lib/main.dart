import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'meal_entry.dart';
import 'onboarding.dart';
import 'supabase_config.dart';
import 'theme.dart';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  runApp(const NutriApp());
}

class NutriApp extends StatelessWidget {
  const NutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutrIA',
      debugShowCheckedModeBanner: false,
      theme: NutriTheme.light(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, _) {
        if (supabase.auth.currentSession == null) return const LoginPage();
        return const ProfileGate();
      },
    );
  }
}

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<bool> _profileReady;

  @override
  void initState() {
    super.initState();
    _profileReady = _checkProfile();
  }

  Future<bool> _checkProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    try {
      final row = await supabase
          .from('profiles')
          .select('height_cm,weight_kg,goal')
          .eq('id', user.id)
          .maybeSingle();
      return row != null &&
          row['height_cm'] != null &&
          row['weight_kg'] != null &&
          row['goal'] != null;
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _profileReady,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const HomePage() : const OnboardingPage();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  int _water = 1250;

  String get _name {
    final user = supabase.auth.currentUser;
    final value = (user?.userMetadata?['full_name'] as String?)?.trim();
    return value?.isNotEmpty == true ? value! : 'Tudo bem por aí?';
  }

  String get _initial {
    final clean = _name.trim();
    return clean.isEmpty ? 'N' : clean.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_dashboard(), _progress(), _profile()];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MealEntryPage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Registrar'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progresso'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _dashboard() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bom dia, $_name 👋', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 5),
                  Text('Seu resumo de hoje', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 23,
              backgroundColor: NutriTheme.mint,
              child: Text(_initial, style: const TextStyle(color: NutriTheme.green, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        NutrIACard(
          child: Column(
            children: [
              Row(children: [const NutrIABadge(text: 'Hoje'), const Spacer(), Flexible(child: Text('Meta 2.100 kcal', textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12))) ]),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth.clamp(150.0, 190.0).toDouble();
                  return SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: 1280 / 2100,
                            strokeWidth: 14,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(34),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('1.280', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                const Text('kcal consumidas'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Row(children: [_Macro(label: 'Carboidratos', value: '156 g'), _Macro(label: 'Proteínas', value: '72 g'), _Macro(label: 'Gorduras', value: '44 g')]),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(children: [Expanded(child: Text('Refeições de hoje', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), TextButton(onPressed: () {}, child: const Text('Ver todas'))]),
        const SizedBox(height: 10),
        const _MealTile(title: 'Café da manhã', description: 'Pão francês com ovo', calories: '310 kcal', icon: Icons.free_breakfast_outlined),
        const SizedBox(height: 10),
        const _MealTile(title: 'Almoço', description: 'Arroz, feijão e frango', calories: '620 kcal', icon: Icons.lunch_dining_outlined),
        const SizedBox(height: 10),
        const _MealTile(title: 'Lanche', description: 'Banana com aveia', calories: '350 kcal', icon: Icons.apple),
        const SizedBox(height: 18),
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
    );
  }

  Widget _progress() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      children: [
        Text('Seu progresso', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Acompanhe seus registros e hábitos ao longo do tempo.'),
        const SizedBox(height: 20),
        NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const NutrIABadge(text: 'Em breve'), const SizedBox(height: 18), Text('Histórico e tendências', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('Gráficos de consumo, frequência de refeições e evolução serão adicionados nesta área.')]))
      ],
    );
  }

  Widget _profile() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      children: [
        Text('Seu perfil', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        NutrIACard(
          child: Column(children: [
            CircleAvatar(radius: 34, backgroundColor: NutriTheme.mint, child: Text(_initial, style: const TextStyle(fontSize: 25, color: NutriTheme.green, fontWeight: FontWeight.w800))),
            const SizedBox(height: 12),
            Text(_name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(supabase.auth.currentUser?.email ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            OutlinedButton.icon(onPressed: () async => supabase.auth.signOut(), icon: const Icon(Icons.logout), label: const Text('Sair da conta')),
          ]),
        ),
      ],
    );
  }
}

class _Macro extends StatelessWidget {
  final String label, value;
  const _Macro({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(children: [FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)],),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final String title, description, calories;
  final IconData icon;
  const _MealTile({required this.title, required this.description, required this.calories, required this.icon});

  @override
  Widget build(BuildContext context) {
    return NutrIACard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: NutriTheme.green)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))])),
        const SizedBox(width: 10),
        SizedBox(width: 70, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(calories, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w800)))),
      ]),
    );
  }
}
