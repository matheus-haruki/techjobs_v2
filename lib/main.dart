import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/modules/app_module.dart';

void main() {
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