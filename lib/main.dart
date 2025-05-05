import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plant_recognition/auth/login.dart';
import 'package:plant_recognition/auth/signup.dart';
import 'package:plant_recognition/ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://ncowkixvuefbtdffkjyb.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jb3draXh2dWVmYnRkZmZranliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzODIxODcsImV4cCI6MjA2MTk1ODE4N30.PcVp1Zts3_4OMuCCw_IKk-O3Am4WgrjXM2CzVv5Itlo',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
