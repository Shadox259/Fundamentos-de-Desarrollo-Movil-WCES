import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class AuthService {
  static User? get currentUser => supabase.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Future<void> signIn(String email, String password) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signUp(String email, String password) async {
    await supabase.auth.signUp(email: email.trim(), password: password);
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}