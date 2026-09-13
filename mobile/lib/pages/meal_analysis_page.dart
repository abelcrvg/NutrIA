import 'package:flutter/material.dart';
import '../supabase_config.dart';
import '../theme.dart';
import '../models/meal_feedback.dart';
import 'meal_matching.dart';

class MealAnalysisPage extends StatelessWidget {
  final String mealName;
  final String mealType;
  final List<MealItemAnalysis> items;
  final num? calories;

  const MealAnalysisPage({super.key, required this.mealName, required this.mealType, required this.items, this.calories});

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
          'name': item.foodName, 'type': item.type, 'is_warning': item.isWarning,
          'detail': item.detail, 'calories': item.calories, 'protein': item.protein,
          'carbs': item.carbs, 'fat': item.fat, 'fiber': item.fiber,
        }).toList(),
      });
      if (context.mounted) Navigator.pop(context, true);
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível registrar: $error')));
    }
  }

  Widget _macro(BuildContext context, String label, String value, IconData icon) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [Icon(icon, size: 20, color: NutriTheme.green), const SizedBox(height: 5), Text(value, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final report = reportFromItems(mealName, items, calories);
    final detailCards = report.itemDetails.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NutrIACard(padding: const EdgeInsets.all(13), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(item.isWarning ? Icons.warning_amber_outlined : Icons.check_circle_outline, color: item.isWarning ? Colors.orange : NutriTheme.green),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.foodName, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(item.detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35)),
          const SizedBox(height: 4),
          Text('${item.calories.toStringAsFixed(0)} kcal • P ${item.protein.toStringAsFixed(1)}g • C ${item.carbs.toStringAsFixed(1)}g • G ${item.fat.toStringAsFixed(1)}g • F ${item.fiber.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ])),
      ])),
    )).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Análise NutrIA')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
        Text(mealName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(mealType),
        const SizedBox(height: 18),
        NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(feedbackIcon(report.overallStatus), color: NutriTheme.green, size: 30), const SizedBox(width: 12), Expanded(child: Text(report.overallTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)))]),
          const SizedBox(height: 14),
          Text(report.overallBody, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
          if (report.improvement.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Como melhorar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(report.improvement, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
          ],
        ])),
        const SizedBox(height: 20),
        Text('Resumo nutricional', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Row(children: [_macro(context, 'Proteína', '${report.protein.toStringAsFixed(1)} g', Icons.fitness_center), const SizedBox(width: 8), _macro(context, 'Carboidratos', '${report.carbs.toStringAsFixed(1)} g', Icons.grain)]),
        const SizedBox(height: 8),
        Row(children: [_macro(context, 'Gorduras', '${report.fat.toStringAsFixed(1)} g', Icons.water_drop_outlined), const SizedBox(width: 8), _macro(context, 'Fibras', '${report.fiber.toStringAsFixed(1)} g', Icons.eco_outlined)]),
        const SizedBox(height: 20),
        Text('Composição da refeição', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...detailCards,
        NutrIACard(child: Row(children: [const Icon(Icons.local_fire_department_outlined, color: Colors.orange), const SizedBox(width: 10), Expanded(child: Text(report.totalCalories > 0 ? '${report.totalCalories.toStringAsFixed(0)} kcal estimadas' : 'Calorias não informadas', style: const TextStyle(fontWeight: FontWeight.w800)))])),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: () => _add(context, report), icon: const Icon(Icons.check), label: const Text('Adicionar ao meu dia')),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.edit_outlined), label: const Text('Voltar e editar')),
      ])),
    );
  }
}
