import 'package:flutter/material.dart';
import '../supabase_config.dart';
import '../theme.dart';
import '../models/meal_log.dart';
import 'meal_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  int _water = 0;
  bool _loading = true;
  List<MealLog> _meals = [];
