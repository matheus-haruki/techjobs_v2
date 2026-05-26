import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'notifications_page.dart';

class NotificationDetailsPage extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailsPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco puro para minimalismo
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove a sombra da barra
        centerTitle: false, // Força o título da Appbar à esquerda
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          'Notificação',
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade400, // Título da AppBar discreto
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Tudo alinhado à esquerda
            children: [
              // Linha Superior: Ícone discreto + Data
              Row(
                children: [
                  Icon(
                    notification.icon,
                    color: notification.iconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    notification.timeAgo.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Título Principal em destaque
              Text(
                notification.title,
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 32),

              // Divisor quase invisível
              Divider(color: Colors.grey.shade100, thickness: 1.5),

              const SizedBox(height: 32),

              // Texto da descrição limpo, sem card/caixa
              Text(
                notification.description,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  height:
                      1.8, // Aumenta o espaçamento entre linhas para leitura
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
