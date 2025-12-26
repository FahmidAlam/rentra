import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager{
  //static final supabase = Supabase.instance.client;
  static SupabaseClient get supabase => Supabase.instance.client;

  static Future<void> init() async{
    await Supabase.initialize(
      url: "https://eurtzaffqqgmzdywdmcy.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1cnR6YWZmcXFnbXpkeXdkbWN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NzQ2MzgsImV4cCI6MjA4MDE1MDYzOH0.pmYFyM8aTp6iBaLu-yjkULZkCNMfgiCgbm6zlBizusc"
    );
  }
}