import 'package:flutter/material.dart';
import 'meal_matching.dart';
import 'meal_adjustment_page.dart';
import '../theme.dart';
import '../supabase_config.dart';
import '../models/meal_feedback.dart';

class MealEntryPage extends StatefulWidget {
  const MealEntryPage({super.key});

  @override
  State<MealEntryPage> createState() => _MealEntryPageState();
}

class _MealEntryPageState extends State<MealEntryPage> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _mealType = 'Almoço';
  bool _isAnalyzing = false;
  final _suggestions = const [
    'Arroz, feijão, ovo e salada',
    'Arroz integral, frango e salada',
    'Macarrão, carne, ovo e salada',
    'Cuscuz com ovo',
    'Açaí, banana e iogurte natural'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _selectSuggestion(String v) {
    _nameController.text = v;
    _nameController.selection = TextSelection.fromPosition(TextPosition(offset: v.length));
    setState(() {});
  }

  Future<void> _analyze() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isAnalyzing = true);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    final report = findMealAnalysisSmart(name, num.tryParse(_caloriesController.text.trim()));
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealAdjustmentPage(mealName: name, mealType: _mealType, items: report.itemDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar refeição')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            const NutrIABadge(text: 'Análise específica'),
            const SizedBox(height: 18),
            Text('O que você comeu?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            const Text('Descreva os alimentos juntos. A ordem não importa: arroz + feijão + frango é a mesma combinação que frango + arroz + feijão.'),
            const SizedBox(height: 24),
            Row(children: [const Expanded(child: _InputOption(icon: Icons.edit_outlined, title: 'Digitar')), const SizedBox(width: 10), Expanded(child: _DisabledInputOption(icon: Icons.photo_camera_outlined, title: 'Foto')), const SizedBox(width: 10), Expanded(child: _DisabledInputOption(icon: Icons.mic_none, title: 'Áudio'))]),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              initialValue: _mealType,
              decoration: const InputDecoration(labelText: 'Tipo de refeição', prefixIcon: Icon(Icons.schedule_outlined)),
              items: const ['Café da manhã', 'Almoço', 'Jantar', 'Lanche', 'Outra'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _mealType = v ?? _mealType),
            ),
            const SizedBox(height: 14),
            TextField(controller: _nameController, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Alimentos', hintText: 'Ex.: arroz, feijão e frango')),
            const SizedBox(height: 14),
            TextField(controller: _caloriesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calorias (opcional)', suffixText: 'kcal')),
            const SizedBox(height: 18),
            const Text('Sugestões rápidas', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: _suggestions.map((s) => ActionChip(label: Text(s), onPressed: () => _selectSuggestion(s))).toList()),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: _isAnalyzing ? null : _analyze, icon: _isAnalyzing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome), label: Text(_isAnalyzing ? 'Analisando...' : 'Analisar refeição')),
          ],
        ),
      ),
    );
  }
}

class _InputOption extends StatelessWidget {
  final IconData icon;
  final String title;
  const _InputOption({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => NutrIACard(padding: const EdgeInsets.symmetric(vertical: 14), child: Column(children: [Icon(icon, color: NutriTheme.green), const SizedBox(height: 5), Text(title, style: const TextStyle(fontWeight: FontWeight.w700))]));
}

class _DisabledInputOption extends StatelessWidget {
  final IconData icon;
  final String title;
  const _DisabledInputOption({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => NutrIACard(padding: const EdgeInsets.symmetric(vertical: 14), child: Column(children: [Icon(icon, color: Colors.grey), const SizedBox(height: 5), Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700))]));
}
