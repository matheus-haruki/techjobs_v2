import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/model/notification_model.dart';

class NotificationDetailsPage extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailsPage({
    super.key,
    required this.notification,
  });

  String _formatDate(DateTime date) {
    // Retorna algo como "03/06/2026 às 15:30"
    return DateFormat("dd/MM/yyyy 'às' HH:mm").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, 
        centerTitle: false, 
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          'Notificação',
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade400, 
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notifications_active, // Ícone genérico padronizado
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(notification.createdAt).toUpperCase(),
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
              Divider(color: Colors.grey.shade100, thickness: 1.5),
              const SizedBox(height: 32),
              Text(
                notification.message, // Alterado para corresponder ao BD
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  height: 1.8, 
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