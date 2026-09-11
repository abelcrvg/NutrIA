import 'package:flutter/material.dart';

class MealEntryPage extends StatefulWidget {
  const MealEntryPage({super.key});

  @override
  State<MealEntryPage> createState() => _MealEntryPageState();
}

class _MealEntryPageState extends State<MealEntryPage> {
  final _nameController = TextEditingController();
  String _mealType = 'Almoço';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refeição pronta para ser analisada.')),
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
          const Text('Começaremos pelo registro manual. O cálculo nutricional será conectado ao banco do NutrIA.'),
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
            decoration: const InputDecoration(
              labelText: 'Refeição ou prato',
              hintText: 'Ex.: arroz, feijão e frango',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Registrar refeição'),
          ),
        ],
      ),
    );
  }
}
