import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserService {
  static final supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>?> fetchCurrentUser() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) return null;

      final uid = firebaseUser.uid;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      return response;
    } catch (e) {
      print("❌ Fetch error: $e");
      return null;
    }
  }
}