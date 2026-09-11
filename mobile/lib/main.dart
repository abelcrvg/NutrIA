import 'package:flutter/material.dart';

void main() {
  runApp(const NutriApp());
}

class NutriApp extends StatelessWidget {
  const NutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutrIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const consumed = 1280;
    const goal = 2100;
    final progress = consumed / goal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutrIA'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Resumo de hoje', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 14,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$consumed kcal', style: Theme.of(context).textTheme.titleLarge),
                            Text('de $goal kcal'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Macro(label: 'Carboidratos', value: '156 g'),
                      _Macro(label: 'Proteínas', value: '72 g'),
                      _Macro(label: 'Gorduras', value: '44 g'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Refeições', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const _MealTile(title: 'Café da manhã', description: 'Pão francês com ovo', calories: '310 kcal'),
          const _MealTile(title: 'Almoço', description: 'Arroz, feijão e frango', calories: '620 kcal'),
          const _MealTile(title: 'Lanche', description: 'Banana com aveia', calories: '350 kcal'),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: const Text('Água'),
              subtitle: const Text('1.250 ml registrados hoje'),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('+250 ml'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Adicionar refeição'),
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  final String label;
  final String value;
  const _Macro({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 3),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  final String title;
  final String description;
  final String calories;
  const _MealTile({required this.title, required this.description, required this.calories});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.restaurant_outlined)),
        title: Text(title),
        subtitle: Text(description),
        trailing: Text(calories),
        onTap: () {},
      ),
    );
  }
}
