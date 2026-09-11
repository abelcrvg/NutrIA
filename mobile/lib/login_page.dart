import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false;
  bool _registering = false;
  bool _obscure = true;

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.length < 6) {
      _message('Informe um e-mail e uma senha com pelo menos 6 caracteres.');
      return;
    }
    setState(() => _loading = true);
    try {
      if (_registering) {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': _name.text.trim()},
        );
        if (!mounted) return;
        if (response.session == null) {
          _message('Conta criada. Confira seu e-mail para confirmar o cadastro.');
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
        }
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } on AuthException catch (e) {
      if (mounted) _message(e.message);
    } catch (_) {
      if (mounted) _message('Não foi possível concluir a operação.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) { _message('Informe seu e-mail primeiro.'); return; }
    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (mounted) _message('Enviamos as instruções de recuperação para seu e-mail.');
    } on AuthException catch (e) { if (mounted) _message(e.message); }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  void dispose() { _email.dispose(); _password.dispose(); _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Icon(Icons.restaurant_menu, size: 64),
              const SizedBox(height: 16),
              Text('NutrIA', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(_registering ? 'Crie sua conta para começar seu diário alimentar.' : 'Seu diário alimentar inteligente.', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              if (_registering) ...[
                TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
                const SizedBox(height: 14),
              ],
              TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(controller: _password, obscureText: _obscure, decoration: InputDecoration(labelText: 'Senha', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
              if (!_registering) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _loading ? null : _resetPassword, child: const Text('Esqueci minha senha'))),
              const SizedBox(height: 8),
              FilledButton(onPressed: _loading ? null : _submit, child: Padding(padding: const EdgeInsets.symmetric(vertical: 13), child: Text(_loading ? 'Aguarde...' : (_registering ? 'Criar conta' : 'Entrar')))),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _loading ? null : () => setState(() => _registering = !_registering), child: Text(_registering ? 'Já tenho uma conta' : 'Criar uma conta')),
            ]),
          ),
        ),
      ),
    ),
  );
}
