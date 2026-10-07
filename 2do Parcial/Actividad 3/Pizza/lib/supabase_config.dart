import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://ioopidtisenwlzrepfng.supabase.co';
  static const String anonKey = 'sb_publishable_HrKiCVWYJeYRHBDlUOF47A_oTok8pes';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

final supabase = Supabase.instance.client;