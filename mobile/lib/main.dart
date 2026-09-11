import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'theme.dart';
import 'pages/auth_gate.dart';
import 'services/feedback_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  await FeedbackService().initialize();
  runApp(const NutriApp());
}

class NutriApp extends StatelessWidget {
  const NutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutrIA',
      debugShowCheckedModeBanner: false,
      theme: NutriTheme.light(),
      home: const AuthGate(),
    );
  }
}
