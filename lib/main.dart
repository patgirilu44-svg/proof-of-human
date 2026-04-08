import 'package:flutter/material.dart';
import 'screens/verify_screen.dart';

void main() {
  runApp(const ProofOfHumanApp());
}

class ProofOfHumanApp extends StatelessWidget {
  const ProofOfHumanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proof of Human',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4FF),
          secondary: Color(0xFF7B2FFF),
          background: Color(0xFF0A0A0A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        useMaterial3: true,
      ),
      home: const VerifyScreen(),
    );
  }
}
