import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart'; // <-- Importante
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/controller/cadidate_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showProfileAvatar; // <-- Nova propriedade opcional

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showProfileAvatar = true, // Por padrão, o avatar aparece
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      centerTitle: false,
      actions: [
        // Se você passou alguma ação extra por parâmetro, ela aparece aqui
        if (actions != null) ...actions!,

        // Exibe o CircleAvatar se a propriedade for true
        if (showProfileAvatar)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Altera dinamicamente para a aba de índice 4 (Perfil)
                Modular.get<CandidateController>().changeTab(4);
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                // Como não temos a foto do backend ainda, usamos um ícone nativo limpo
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
