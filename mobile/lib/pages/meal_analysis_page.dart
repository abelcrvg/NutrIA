import 'package:flutter/material.dart';
import '../models/meal_feedback.dart';
import '../supabase_config.dart';
import '../theme.dart';
import 'meal_matching.dart';

class MealAnalysisPage extends StatelessWidget {
  final String mealName;
  final String mealType;
  final num? calories;

  const MealAnalysisPage({
    super.key,
    required this.mealName,
    required this.mealType,
    this.calories,
  });

  Future<void> _add(BuildContext context, MealAnalysisReport report) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('meals').insert({
        'user_id': user.id,
        'meal_type': mealType,
        'meal_name': mealName,
        'calories': report.totalCalories.toDouble(),
        'source': 'manual',
        'ingredients': report.itemDetails.map((item) => {
          'name': item.foodName,
          'type': item.type,
          'is_warning': item.isWarning,
          'detail': item.detail,
          'calories': item.actualCalories,
        }).toList(),
      });
      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível registrar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = findMealAnalysisSmart(mealName, calories);

    return Scaffold(
      appBar: AppBar(title: const Text('Análise NutrIA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(mealName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(mealType),
            const SizedBox(height: 18),
            NutrIACard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(feedbackIcon(report.overallStatus), color: NutriTheme.green, size: 30),
                      const SizedBox(width: 12),
                      Expanded(child: Text(report.overallTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(report.overallBody, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                  if (report.improvement.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Como melhorar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(report.improvement, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Composição do prato', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...report.itemDetails.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.isWarning ? Icons.warning_amber_outlined : Icons.check_circle_outline, color: item.isWarning ? Colors.orange : NutriTheme.green),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.foodName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(item.detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35)),
                  ])),
                ],
              ),
            )),
            const SizedBox(height: 10),
            NutrIACard(
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_outlined, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    report.totalCalories > 0 ? '${report.totalCalories.toStringAsFixed(0)} kcal estimadas' : 'Calorias não informadas',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 18),
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
