// Ejemplo de uso: copia lo que necesites a tu lib/main.dart.

import 'package:flutter/material.dart';

import 'splash/fbu_splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FbuApp());
}

class FbuApp extends StatelessWidget {
  const FbuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Between Us',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: FbuColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: FbuColors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashGate(),
    );
  }
}

/// Lanza el arranque una sola vez y muestra el splash mientras tanto.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  late final Future<void> _init = _initApp();

  Future<void> _initApp() async {
    // Aquí va tu arranque real, por ejemplo:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FbuSplashScreen(waitFor: _init, onFinished: _goHome);
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Inicio')),
    );
  }
}
