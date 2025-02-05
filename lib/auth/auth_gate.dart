import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_nexus_mobile_app/onboarding.dart';
import 'package:chat_nexus_mobile_app/myHomePage.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      setState(() {
        _user = session?.user;
        _isLoading = false;
      });

      print('Current User: $_user');
      print('Current Session: $session');
    } catch (e) {
      print('Error checking current user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _user != null ? const MyHomePage() : const Onboarding();
  }
}