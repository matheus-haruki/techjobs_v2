import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/style/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ), // Garante que o botão de voltar fique visível sobre o fundo escuro
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      actions: actions,
    );
  }

  // Define o tamanho padrão da AppBar (56.0 lógico é o padrão do Material Design)
  @override
  Size get preferredSize => const Size.fromHeight(80);
}
