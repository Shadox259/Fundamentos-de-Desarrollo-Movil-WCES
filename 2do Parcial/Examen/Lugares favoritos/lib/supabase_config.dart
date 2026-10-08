import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://pxbinfkvngrzetgnurwu.supabase.co';
  static const String anonKey = 'sb_publishable_3hPbEl5D0em6N4WKKvoehA_sMLo-KpS';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

final supabase = Supabase.instance.client;