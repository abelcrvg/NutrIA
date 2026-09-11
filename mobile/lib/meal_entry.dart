import 'package:flutter/material.dart';
import 'meal_feedback_catalog.dart';
import 'theme.dart';

class MealEntryPage extends StatefulWidget {
  const MealEntryPage({super.key});

  @override
  State<MealEntryPage> createState() => _MealEntryPageState();
}

class _MealEntryPageState extends State<MealEntryPage> {
  final _nameController = TextEditingController();
  String _mealType = 'Almoço';
  bool _isAnalyzing = false;

  final _suggestions = const [
    'Arroz, feijão, ovo e salada',
    'Arroz integral, frango e salada',
    'Macarrão, carne, ovo e salada',
    'Cuscuz com ovo',
    'Açaí, banana e iogurte natural',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectSuggestion(String value) {
    _nameController.text = value;
    _nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
    setState(() {});
  }

  Future<void> _analyze() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isAnalyzing = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealAnalysisPage(mealName: name, mealType: _mealType),
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
            Text(
              'Descreva os alimentos juntos. O NutrIA procura primeiro uma combinação específica no catálogo.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: _InputOption(icon: Icons.edit_outlined, title: 'Digitar', selected: true)),
                const SizedBox(width: 10),
                const Expanded(child: _InputOption(icon: Icons.photo_camera_outlined, title: 'Foto', selected: false)),
                const SizedBox(width: 10),
                const Expanded(child: _InputOption(icon: Icons.mic_none, title: 'Áudio', selected: false)),
              ],
            ),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              value: _mealType,
              decoration: const InputDecoration(
                labelText: 'Tipo de refeição',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              items: const ['Café da manhã', 'Almoço', 'Jantar', 'Lanche', 'Outra']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _mealType = value ?? _mealType),
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
              children: _suggestions
                  .map((item) => ActionChip(label: Text(item), onPressed: () => _selectSuggestion(item)))
                  .toList(),
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
            Text(
              'Foto e áudio serão ativados em uma próxima etapa.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
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
  final bool selected;

  const _InputOption({required this.icon, required this.title, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? NutriTheme.mint : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? NutriTheme.green : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: selected ? NutriTheme.green : null),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? NutriTheme.green : null,
            ),
          ),
        ],
      ),
    );
  }
}

class MealAnalysisPage extends StatelessWidget {
  final String mealName;
  final String mealType;

  const MealAnalysisPage({super.key, required this.mealName, required this.mealType});

  @override
  Widget build(BuildContext context) {
    final feedback = findMealFeedback(mealName);
    final status = feedback?.status ?? 'information';
    return Scaffold(
      appBar: AppBar(title: const Text('Análise NutrIA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Text(
              mealName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(mealType, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            if (feedback != null) const NutrIABadge(text: 'Combinação reconhecida pelo catálogo'),
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
                        decoration: BoxDecoration(
                          color: NutriTheme.mint,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(feedbackIcon(status), color: NutriTheme.green, size: 27),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          feedback?.title ?? 'Ainda estamos ampliando o catálogo',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    feedback?.body ?? 'Ainda não há uma análise específica cadastrada para esta combinação. Inclua os principais alimentos da refeição para facilitar o reconhecimento.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  if (feedback != null) ...[
                    const SizedBox(height: 22),
                    Container(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                    const SizedBox(height: 18),
                    Text('Como melhorar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    Text(feedback.improvement, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            NutrIACard(
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: NutriTheme.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O NutrIA considera a combinação informada, não apenas um alimento isolado.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar refeição'),
            ),
          ],
        ),
      ),
    );
  }
}
