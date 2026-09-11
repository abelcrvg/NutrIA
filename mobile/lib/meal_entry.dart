import 'package:flutter/material.dart';
import 'meal_feedback_catalog.dart';

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
    'Arroz, feijão, ovo e salada', 'Macarrão, carne e salada',
    'Hambúrguer e batata frita', 'Açaí com banana',
    'Iogurte, banana e aveia',
  ];

  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  void _selectSuggestion(String value) {
    _nameController.text = value;
    _nameController.selection = TextSelection.fromPosition(TextPosition(offset: value.length));
    setState(() {});
  }

  Future<void> _analyze() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isAnalyzing = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    Navigator.push(context, MaterialPageRoute(builder: (_) => MealAnalysisPage(mealName: name, mealType: _mealType)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Adicionar refeição')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('O que você comeu?', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Descreva os alimentos juntos. O NutrIA procura primeiro uma análise específica da combinação.'),
      const SizedBox(height: 24),
      DropdownButtonFormField<String>(value: _mealType, decoration: const InputDecoration(labelText: 'Tipo de refeição', border: OutlineInputBorder()), items: const ['Café da manhã', 'Almoço', 'Jantar', 'Lanche', 'Outra'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(), onChanged: (value) => setState(() => _mealType = value ?? _mealType)),
      const SizedBox(height: 16),
      TextField(controller: _nameController, textCapitalization: TextCapitalization.sentences, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Refeição ou prato', hintText: 'Ex.: arroz, feijão e frango', border: OutlineInputBorder(), prefixIcon: Icon(Icons.restaurant_outlined))),
      const SizedBox(height: 20),
      Text('Sugestões', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: _suggestions.map((item) => ActionChip(label: Text(item), onPressed: () => _selectSuggestion(item))).toList()),
      const SizedBox(height: 28),
      FilledButton.icon(onPressed: _isAnalyzing || _nameController.text.trim().isEmpty ? null : _analyze, icon: _isAnalyzing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome), label: Text(_isAnalyzing ? 'Analisando...' : 'Analisar refeição')),
    ]),
  );
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
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(mealName, style: Theme.of(context).textTheme.headlineSmall),
        Text(mealType, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        if (feedback != null) Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(context).colorScheme.secondaryContainer),
          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.auto_awesome, size: 18), const SizedBox(width: 8), Text('Combinação reconhecida pelo catálogo NutrIA', style: Theme.of(context).textTheme.labelLarge)]),
        ),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(feedbackIcon(status), size: 30), const SizedBox(width: 10), Expanded(child: Text(feedback?.title ?? 'Análise em preparação', style: Theme.of(context).textTheme.titleLarge))]),
          const SizedBox(height: 14),
          Text(feedback?.body ?? 'Ainda não há uma combinação específica cadastrada para esta entrada. O catálogo será usado como base para futuras análises.'),
          if (feedback != null) ...[const SizedBox(height: 20), Text('Como melhorar', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 6), Text(feedback.improvement)],
        ]))),
        const SizedBox(height: 16),
        if (feedback == null) Card(child: ListTile(leading: const Icon(Icons.info_outline), title: const Text('Análise específica ainda não disponível'), subtitle: const Text('Tente incluir os principais alimentos da refeição para aumentar a chance de encontrar uma combinação cadastrada.'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.edit_outlined), label: const Text('Editar refeição')),
      ]),
    );
  }
}
