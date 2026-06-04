import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Novo import!
import 'package:techjobs/modules/app_module.dart';

// O main agora é assíncrono (async)
void main() async {
  // 1. Garante que os widgets do Flutter estejam prontos antes de chamar conexões externas
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Supabase com as suas chaves reais
  await Supabase.initialize(
    url: 'https://ijaplqqiwqislviqvizu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqYXBscXFpd3Fpc2x2aXF2aXp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxNzc1MjYsImV4cCI6MjA5NTc1MzUyNn0.i-AeEFA4llQA0_2t6F-3XirngsoiXowffFKW88qxzFg',
  );

  // 3. Inicia o app com o Modular
  runApp(
    ModularApp(
      module: AppModule(), // Inicializa o módulo principal
      child: const AppWidget(), // Inicializa o widget principal
    ),
  );
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Substituímos o MaterialApp padrão pelo MaterialApp.router
    return MaterialApp.router(
      title: 'TechJobs',
      debugShowCheckedModeBanner: false, // Remove a faixa de "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A92AA)),
        useMaterial3: true,
      ),
      // Esta linha entrega o controle de navegação para o Modular
      routerConfig: Modular.routerConfig,
    );
  }
}
