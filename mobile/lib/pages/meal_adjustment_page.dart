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
    required this.items,
  });

  @override
  State<MealAdjustmentPage> createState() => _MealAdjustmentPageState();
}

class _MealAdjustmentPageState extends State<MealAdjustmentPage> {
  late List<Map<String, dynamic>> _adjustableItems;
  late List<TextEditingController> _quantityControllers;

  @override
  void initState() {
    super.initState();
    _adjustableItems = widget.items.map((item) {
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
    _quantityControllers = List.generate(
      _adjustableItems.length,
      (_) => TextEditingController(text: '1'),
    );
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
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

  void _setQuantity(int index, double value) {
    final quantity = value.clamp(0.5, 99.0).toDouble();
    setState(() {
      _adjustableItems[index]['quantity'] = quantity;
      _quantityControllers[index].text = quantity % 1 == 0
          ? quantity.toStringAsFixed(0)
          : quantity.toStringAsFixed(1);
      _quantityControllers[index].selection = TextSelection.collapsed(
        offset: _quantityControllers[index].text.length,
      );
    });
  }

  void _changeQuantity(int index, double delta) {
    final current = _adjustableItems[index]['quantity'] as double;
    _setQuantity(index, current + delta);
  }

  void _removeItem(int index) {
    final controller = _quantityControllers.removeAt(index);
    controller.dispose();
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      analysis.foodName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      analysis.name,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remover alimento',
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 72,
                                child: TextField(
                                  controller: _quantityControllers[index],
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    labelText: 'Qtd.',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    final parsed = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (parsed != null && parsed > 0) {
                                      _adjustableItems[index]['quantity'] = parsed;
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                height: 48,
                                width: 36,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Aumentar quantidade',
                                        icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                                        onPressed: () => _changeQuantity(index, 0.5),
                                      ),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Diminuir quantidade',
                                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                        onPressed: () => _changeQuantity(index, -0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: item['unit'],
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Unidade',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: analysis.unitWeights.keys
                                      .map(
                                        (u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(
                                            u,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => item['unit'] = v);
                                    }
                                  },
                                ),
                              ),
                            ],
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
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: .3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Estimado:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${totalCals.toStringAsFixed(0)} kcal',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: NutriTheme.green,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
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
