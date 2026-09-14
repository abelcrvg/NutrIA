import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../supabase_config.dart';

class ProductSubmissionPage extends StatefulWidget {
  final String initialName;
  const ProductSubmissionPage({super.key, required this.initialName});

  @override
  State<ProductSubmissionPage> createState() => _ProductSubmissionPageState();
}

class _ProductSubmissionPageState extends State<ProductSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _barcode = TextEditingController();
  final _servingSize = TextEditingController();
  final _servingUnit = TextEditingController(text: 'g');
  final _calories = TextEditingController();
  final _carbs = TextEditingController();
  final _sugarsTotal = TextEditingController();
  final _sugarsAdded = TextEditingController();
  final _protein = TextEditingController();
  final _fat = TextEditingController();
  final _saturatedFat = TextEditingController();
  final _fiber = TextEditingController();
  final _sodium = TextEditingController();
  final _ingredients = TextEditingController();
  final _picker = ImagePicker();
  XFile? _labelPhoto;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialName;
  }

  @override
  void dispose() {
    for (final c in [
      _name, _brand, _barcode, _servingSize, _servingUnit, _calories,
      _carbs, _sugarsTotal, _sugarsAdded, _protein, _fat, _saturatedFat,
      _fiber, _sodium, _ingredients,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _number(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (!mounted || photo == null) return;
    setState(() => _labelPhoto = photo);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_labelPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A foto da tabela nutricional é obrigatória para enviar o produto.')),
      );
      return;
    }
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entre na sua conta para enviar um produto.')));
      return;
    }

    setState(() => _sending = true);
    try {
      final submissionId = '${DateTime.now().microsecondsSinceEpoch}';
      final extension = _labelPhoto!.path.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      final path = '${user.id}/$submissionId.$extension';
      await supabase.storage.from('product-labels').upload(path, File(_labelPhoto!.path));

      final extractedData = <String, dynamic>{
        'product_name': _name.text.trim(),
        'brand': _brand.text.trim(),
        'barcode': _barcode.text.trim(),
        'serving_size': _number(_servingSize),
        'serving_unit': _servingUnit.text.trim(),
        'calories': _number(_calories),
        'carbohydrates': _number(_carbs),
        'sugars_total': _number(_sugarsTotal),
        'sugars_added': _number(_sugarsAdded),
        'protein': _number(_protein),
        'total_fat': _number(_fat),
        'saturated_fat': _number(_saturatedFat),
        'fiber': _number(_fiber),
        'sodium': _number(_sodium),
        'ingredients': _ingredients.text.trim(),
        'source': 'user_submission',
      };

      await supabase.from('product_submissions').insert({
        'barcode': _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
        'submitted_by': user.id,
        'photo_path': path,
        'extracted_data': extractedData,
        'status': 'pending',
      });

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enviado para avaliação'),
          content: const Text('O produto foi enviado com a foto da tabela nutricional. Ele só entrará no catálogo validado depois da revisão administrativa.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível enviar: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(labelText: label, hintText: hint);

  Widget _field(TextEditingController controller, String label, {TextInputType? keyboard, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: _dec(label, hint: hint),
        validator: label == 'Nome do produto' ? (v) => v == null || v.trim().isEmpty ? 'Informe o nome.' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar produto')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              const Text('Produto não encontrado', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Envie os dados disponíveis e uma foto legível da tabela nutricional. A equipe administra a validação antes de liberar o produto para todos.'),
              const SizedBox(height: 20),
              _field(_name, 'Nome do produto'),
              _field(_brand, 'Marca'),
              _field(_barcode, 'Código de barras (EAN)', keyboard: TextInputType.number),
              const SizedBox(height: 6),
              Text('Tabela nutricional', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _field(_servingSize, 'Porção', keyboard: const TextInputType.numberWithOptions(decimal: true))),
                const SizedBox(width: 10),
                Expanded(child: _field(_servingUnit, 'Unidade')),
              ]),
              _field(_calories, 'Calorias (kcal)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_carbs, 'Carboidratos (g)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_sugarsTotal, 'Açúcares totais (g)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_sugarsAdded, 'Açúcares adicionados (g)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_protein, 'Proteínas (g)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_fat, 'Gorduras totais (g)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_saturatedFat, 'Gorduras saturadas (g)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_fiber, 'Fibras (g)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_sodium, 'Sódio (mg)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
              _field(_ingredients, 'Ingredientes', hint: 'Opcional nesta primeira etapa'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _sending ? null : _pickPhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(_labelPhoto == null ? 'Fotografar tabela nutricional *' : 'Trocar foto da tabela'),
              ),
              if (_labelPhoto != null) ...[
                const SizedBox(height: 10),
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_labelPhoto!.path), height: 180, fit: BoxFit.cover)),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _sending ? null : _submit,
                icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_outlined),
                label: Text(_sending ? 'Enviando...' : 'Enviar para avaliação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
