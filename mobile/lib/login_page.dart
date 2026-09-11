import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false, _registering = false, _obscure = true;

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@') || password.length < 6) { _message('Informe um e-mail válido e uma senha com pelo menos 6 caracteres.'); return; }
    if (_registering && _name.text.trim().isEmpty) { _message('Informe seu nome para criar a conta.'); return; }
    setState(() => _loading = true);
    try {
      if (_registering) {
        final response = await supabase.auth.signUp(email: email, password: password, data: {'full_name': _name.text.trim()});
        if (!mounted) return;
        if (response.session == null) _message('Conta criada. Confira seu e-mail para confirmar o cadastro.');
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (e) { if (mounted) _message(e.message); }
    catch (_) { if (mounted) _message('Não foi possível concluir a operação.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) { _message('Informe seu e-mail primeiro.'); return; }
    try { await supabase.auth.resetPasswordForEmail(email); if (mounted) _message('Enviamos as instruções de recuperação para seu e-mail.'); }
    on AuthException catch (e) { if (mounted) _message(e.message); }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  void dispose() { _email.dispose(); _password.dispose(); _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Center(child: Container(width: 76, height: 76, decoration: BoxDecoration(color: NutriTheme.mint, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.spa_outlined, size: 42, color: NutriTheme.green))),
    const SizedBox(height: 22),
    Text('NutrIA', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: NutriTheme.green)),
    const SizedBox(height: 7),
    Text(_registering ? 'Comece seu diário alimentar.' : 'Entenda melhor o que você come.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
    const SizedBox(height: 30),
    NutrIACard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(_registering ? 'Criar conta' : 'Entrar', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 18),
      if (_registering) ...[TextField(controller: _name, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 12)],
      TextField(controller: _email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined))),
      const SizedBox(height: 12),
      TextField(controller: _password, obscureText: _obscure, onSubmitted: (_) => _loading ? null : _submit(), decoration: InputDecoration(labelText: 'Senha', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
      if (!_registering) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _loading ? null : _resetPassword, child: const Text('Esqueci minha senha'))),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: _loading ? null : _submit, icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(_registering ? Icons.person_add_alt_1 : Icons.login), label: Text(_loading ? 'Aguarde...' : (_registering ? 'Criar minha conta' : 'Entrar'))),
      const SizedBox(height: 10),
      TextButton(onPressed: _loading ? null : () => setState(() => _registering = !_registering), child: Text(_registering ? 'Já tenho uma conta' : 'Ainda não tenho conta')),
    ])),
    const SizedBox(height: 20),
    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_outline, size: 14), SizedBox(width: 6), Text('Seus dados ficam vinculados à sua conta', style: TextStyle(fontSize: 12))]),
  ])))));
}
