import 'package:flutter/material.dart';
import '../models/meal_feedback.dart';
import '../theme.dart';
import 'meal_analysis_page.dart';

class MealAdjustmentPage extends StatefulWidget {
  final String mealName, mealType;
  final List<MealItemAnalysis> items;

  const MealAdjustmentPage({
    super.key,
    required this.mealName,
    required this.mealType,
    required this.items
  });

  @override
  State<MealAdjustmentPage> createState() => _MealAdjustmentPageState();
}

class _MealAdjustmentPageState extends State<MealAdjustmentPage> {
  late List<Map<String, dynamic>> _adjustableItems;

  @override
  void initState() {
    super.initState();
    _adjustableItems = widget.items.map((item) {
      // Find default unit if possible
      String defaultUnit = 'unidade';
      if (item.unitWeights.isNotEmpty) {
        defaultUnit = item.unitWeights.keys.first;
      }
      return {
        'analysis': item,
        'quantity': 1.0,
        'unit': defaultUnit,
      };
    }).toList();
  }

  double _calculateTotalCalories() {
    double total = 0;
    for (var item in _adjustableItems) {
      final analysis = item['analysis'] as MealItemAnalysis;
      final qty = item['quantity'] as double;
      final unit = item['unit'] as String;

      final weightPerUnit = analysis.unitWeights[unit] ?? 1.0;
      final totalGrams = qty * weightPerUnit;
      total += (totalGrams * analysis.caloriesPer100g) / 100;
    }
    return total;
  }

  void _removeItem(int index) {
    setState(() => _adjustableItems.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final totalCals = _calculateTotalCalories();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustar Porções')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _adjustableItems.length,
                itemBuilder: (context, index) {
                  final item = _adjustableItems[index];
                  final analysis = item['analysis'] as MealItemAnalysis;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(analysis.foodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(analysis.name, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(hintText: '1'),
                                    onChanged: (v) => setState(() => item['quantity'] = double.tryParse(v) ?? 1.0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: item['unit'],
                                  isDense: true,
                                  items: analysis.unitWeights.keys.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                  onChanged: (v) => setState(() => item['unit'] = v!),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimado:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('${totalCals.toStringAsFixed(0)} kcal', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        // Recalculate final analysis based on adjusted totals
                        // We pass the total calories to the analysis page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealAnalysisPage(
                              mealName: widget.mealName,
                              mealType: widget.mealType,
                              calories: totalCals,
                            ),
                          ),
                        );
                      },
                      child: const Text('Ver Análise Final'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
