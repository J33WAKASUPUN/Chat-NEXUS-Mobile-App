import 'package:chat_nexus_mobile_app/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_nexus_mobile_app/themes.dart';


final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   await dotenv.load(fileName: ".env");

  try {
    await Supabase.initialize(
      url: 'https://asiqunfpbxnetzumiifp.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzaXF1bmZwYnhuZXR6dW1paWZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0NTQ3MjQsImV4cCI6MjA1NDAzMDcyNH0.G5dOxUKFR9s4sqdR5oO_2gm_LLVgHQcmZYMfRXmiEeo',
      debug: true,
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Supabase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Chat Nexus',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: currentThemeMode,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
