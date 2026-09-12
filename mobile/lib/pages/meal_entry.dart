import 'package:flutter/material.dart';
import 'meal_matching.dart';
import '../theme.dart';
import '../supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealAnalysisPage(
          mealName: name,
          mealType: _mealType,
          calories: num.tryParse(_caloriesController.text.trim()),
        ),
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
            Text(
              'O que você comeu?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            const Text(
              'Descreva os alimentos juntos. A ordem não importa: arroz + feijão + frango é a mesma combinação que frango + arroz + feijão.',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: _InputOption(icon: Icons.edit_outlined, title: 'Digitar')),
                const SizedBox(width: 10),
                Expanded(child: _DisabledInputOption(icon: Icons.photo_camera_outlined, title: 'Foto')),
                const SizedBox(width: 10),
                Expanded(child: _DisabledInputOption(icon: Icons.mic_none, title: 'Áudio')),
              ],
            ),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              value: _mealType,
              decoration: const InputDecoration(labelText: 'Tipo de refeição', prefixIcon: Icon(Icons.schedule_outlined)),
              items: const [
                'Café da manhã',
                'Almoço',
                'Jantar',
                'Lanche',
                'Outra'
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _mealType = v ?? _mealType),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Refeição ou prato',
                hintText: 'Ex.: arroz, feijão, frango e salada',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 38),
                  child: Icon(Icons.restaurant_outlined),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calorias (opcional)',
                hintText: 'Ex.: 520',
                suffixText: 'kcal',
                prefixIcon: Icon(Icons.local_fire_department_outlined),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sugestões rápidas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const Icon(Icons.touch_app_outlined, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((item) => ActionChip(label: Text(item), onPressed: () => _selectSuggestion(item))).toList(),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _isAnalyzing || _nameController.text.trim().isEmpty ? null : _analyze,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isAnalyzing ? 'Analisando...' : 'Analisar refeição'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Analisar não adiciona a refeição. Você sempre confirma antes de registrar.',
              textAlign: TextAlign.center,
            ),
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: NutriTheme.mint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NutriTheme.green),
        ),
        child: Column(
          children: [
            Icon(icon, color: NutriTheme.green),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NutriTheme.green)),
          ],
        ),
      );
}

class _DisabledInputOption extends StatelessWidget {
  final IconData icon;
  final String title;
  const _DisabledInputOption({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).disabledColor),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).disabledColor)),
          ],
        ),
      );
}

class MealAnalysisPage extends StatelessWidget {
  final String mealName, mealType;
  final num? calories;
  const MealAnalysisPage({super.key, required this.mealName, required this.mealType, this.calories});

  Future<void> _add(BuildContext context, MealAnalysisReport report) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase.from('meals').insert({
        'user_id': user.id,
        'meal_type': mealType,
        'meal_name': mealName,
        'calories': calories?.toDouble(),
        'source': 'manual',
        'ingredients': report.itemDetails.map((i) => {
          'name': i.name,
          'type': i.type,
          'is_warning': i.isWarning,
          'detail': i.detail,
        }).toList(),
      });
      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = findMealAnalysisSmart(mealName, calories);
    final status = report.overallStatus;

    return Scaffold(
      appBar: AppBar(title: const Text('Análise NutrIA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Text(mealName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(mealType),
            const SizedBox(height: 16),
            NutrIACard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(15)),
                        child: Icon(feedbackIcon(status), color: NutriTheme.green, size: 27),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          report.overallTitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(report.overallBody, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                  if (report.improvement.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Container(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                    const SizedBox(height: 18),
                    Text('Como melhorar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    Text(report.improvement, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Composição do Prato', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...report.itemDetails.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: item.isWarning ? Colors.amber : NutriTheme.mint,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: item.isWarning ? Colors.orange : NutriTheme.green),
                        ),
                        child: Icon(
                          item.isWarning ? Icons.warning : Icons.check,
                          size: 16,
                          color: item.isWarning ? Colors.orange : NutriTheme.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(item.detail, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey)),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            NutrIACard(
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.totalCalories == 0
                          ? 'Calorias não informadas.'
                          : '${report.totalCalories} kcal estimadas para este prato.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _add(context, report),
              icon: const Icon(Icons.check),
              label: const Text('Adicionar ao meu dia'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Voltar e editar'),
            ),
          ],
        ),
      ),
    );
  }
}
