import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _name = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  String _goal = 'maintain';
  bool _loading = false;

  final goals = const [
    ('lose_weight', 'Perder peso', Icons.trending_down),
    ('maintain', 'Manter o peso', Icons.balance),
    ('gain_weight', 'Ganhar peso', Icons.trending_up),
    ('gain_muscle', 'Ganhar massa muscular', Icons.fitness_center),
  ];

  Future<void> _finish() async {
    final height = double.tryParse(_height.text.replaceAll(',', '.'));
    final weight = double.tryParse(_weight.text.replaceAll(',', '.'));
    if (_name.text.trim().isEmpty || height == null || weight == null || height < 80 || weight < 25) {
      _message('Preencha nome, altura e peso com valores válidos.');
      return;
    }
    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('profiles').upsert({'id': user.id, 'full_name': _name.text.trim(), 'height_cm': height, 'weight_kg': weight, 'goal': _goal});
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
    } on PostgrestException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('Não foi possível salvar seu perfil. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  void dispose() { _name.dispose(); _height.dispose(); _weight.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 28, 24, 32), children: [
      const NutrIABadge(text: 'Seu perfil NutrIA'),
      const SizedBox(height: 24),
      Text('Vamos personalizar\nsua experiência.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.1)),
      const SizedBox(height: 10),
      Text('Esses dados ajudam o app a organizar seu diário. Você poderá ajustá-los depois.', style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 28),
      TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Como podemos chamar você?', prefixIcon: Icon(Icons.person_outline))),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: TextField(controller: _height, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Altura', suffixText: 'cm'))), const SizedBox(width: 12), Expanded(child: TextField(controller: _weight, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso', suffixText: 'kg')))]),
      const SizedBox(height: 26),
      Text('Qual é seu objetivo?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      ...goals.map((item) => Padding(padding: const EdgeInsets.only(bottom: 9), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => setState(() => _goal = item.$1), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: _goal == item.$1 ? NutriTheme.mint : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _goal == item.$1 ? NutriTheme.green : Theme.of(context).colorScheme.outlineVariant, width: _goal == item.$1 ? 1.5 : 1)), child: Row(children: [Icon(item.$3, color: _goal == item.$1 ? NutriTheme.green : null), const SizedBox(width: 12), Expanded(child: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w600))), Icon(_goal == item.$1 ? Icons.radio_button_checked : Icons.radio_button_off, color: _goal == item.$1 ? NutriTheme.green : null)]))))),
      const SizedBox(height: 18),
      FilledButton(onPressed: _loading ? null : _finish, child: Text(_loading ? 'Salvando...' : 'Começar no NutrIA')),
    ])),
  );
}
