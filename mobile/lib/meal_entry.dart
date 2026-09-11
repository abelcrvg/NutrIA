import 'package:flutter/material.dart';

class MealEntryPage extends StatefulWidget {
  const MealEntryPage({super.key});

  @override
  State<MealEntryPage> createState() => _MealEntryPageState();
}

class _MealEntryPageState extends State<MealEntryPage> {
  final _nameController = TextEditingController();
  String _mealType = 'Almoço';

  final _suggestions = const [
    'Arroz, feijão e frango',
    'Strogonoff com arroz',
    'Macarrão à bolonhesa',
    'Açaí com banana e aveia',
    'Iogurte natural com banana e aveia',
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

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name registrado em $_mealType.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar refeição')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('O que você comeu?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Registre o prato e depois o NutrIA poderá calcular os nutrientes e aplicar o feedback específico da combinação.'),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _mealType,
            decoration: const InputDecoration(labelText: 'Tipo de refeição', border: OutlineInputBorder()),
            items: const ['Café da manhã', 'Almoço', 'Jantar', 'Lanche', 'Outra']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _mealType = value ?? _mealType),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Refeição ou prato',
              hintText: 'Ex.: arroz, feijão e frango',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text('Exemplos rápidos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((item) => ActionChip(
              label: Text(item),
              onPressed: () => _selectSuggestion(item),
            )).toList(),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _nameController.text.trim().isEmpty ? null : _save,
            icon: const Icon(Icons.check),
            label: const Text('Registrar refeição'),
          ),
        ],
      ),
    );
  }
}
