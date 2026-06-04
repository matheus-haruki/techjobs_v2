import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/controller/candidate_controller.dart';
import 'package:techjobs/modules/candidato/controller/candidate_profile_controller.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showProfileAvatar;
  final VoidCallback? onAvatarTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showProfileAvatar = true,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
      ),
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
        if (actions != null) ...actions!,
        if (showProfileAvatar)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _ReactiveAvatarWidget(onTap: onAvatarTap),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showProfileAvatar;
  final VoidCallback? onAvatarTap;

  const CustomAppBar2({
    super.key,
    required this.title,
    this.actions,
    this.showProfileAvatar = true,
    this.onAvatarTap,
  });

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
            colors: [AppColors.secondaryDark, AppColors.secondary],
          ),
        ),
      ),
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
        if (actions != null) ...actions!,
        if (showProfileAvatar)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _ReactiveAvatarWidget(onTap: onAvatarTap),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Componente isolado que lida com a lógica de buscar a foto de perfil.
/// Pode ser usado livremente em qualquer das duas AppBars.
class _ReactiveAvatarWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const _ReactiveAvatarWidget({this.onTap});

  @override
  Widget build(BuildContext context) {
    final Widget fallbackAvatar = const CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white24,
      child: Icon(Icons.person, color: Colors.white, size: 20),
    );

    // Função que envolve o avatar com a ação de clique
    Widget buildTapAction(Widget child) {
      return GestureDetector(
        onTap:
            onTap ??
            () {
              try {
                // Recupera o controller global que gerencia a BaseCandidatePage
                final baseController = Modular.get<CandidateController>();

                // Manda mudar para a aba do Perfil.
                // Altere o número (4) para o índice correto da sua aba de Perfil!
                // (Ex: 0=Feed, 1=Busca, 2=Conexões, 3=Notificações, 4=Perfil)
                baseController.changeTab(4);
              } catch (e) {
                debugPrint('Erro ao mudar de aba: $e');
              }
            },
        child: child,
      );
    }

    try {
      final controller = Modular.get<CandidateProfileController>();

      return buildTapAction(
        ValueListenableBuilder<AppState<CandidateModel>>(
          valueListenable: controller,
          builder: (context, state, child) {
            String? avatarUrl;

            if (state is SuccessState<CandidateModel>) {
              avatarUrl = state.data.avatarUrl;
            }

            return CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            );
          },
        ),
      );
    } catch (e) {
      // Caso o Controller não seja encontrado (ex: módulo da empresa), exibe o fallback
      return buildTapAction(fallbackAvatar);
    }
  }
}
