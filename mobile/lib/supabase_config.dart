import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://mkckjeheeuwfzxfexese.supabase.co';
const supabasePublishableKey = 'sb_publishable_7r495qqp9Ogd7wcgKuDi-A_ymT6Bohp';

final supabase = Supabase.instance.client;

Future<void> initializeSupabase() async {
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
}
