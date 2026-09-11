import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'profile_gate.dart';

final supabase = Supabase.instance.client;

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, _) {
        return supabase.auth.currentSession == null
            ? const LoginPage()
            : const ProfileGate();
      },
    );
  }
}
