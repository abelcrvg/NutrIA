import 'package:flutter/material.dart';
import '../supabase_config.dart';
import 'home_page.dart';
import 'onboarding.dart';

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<bool> _profileReady;

  @override
  void initState() {
    super.initState();
    _profileReady = _checkProfile();
  }

  Future<bool> _checkProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    try {
      final row = await supabase
          .from('profiles')
          .select('height_cm,weight_kg,goal')
          .eq('id', user.id)
          .maybeSingle();
      return row != null &&
          row['height_cm'] != null &&
          row['weight_kg'] != null &&
          row['goal'] != null;
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _profileReady,
      builder: (context, s) {
        if (!s.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return s.data! ? const HomePage() : const OnboardingPage();
      },
    );
  }
}
