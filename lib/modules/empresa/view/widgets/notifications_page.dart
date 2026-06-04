import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';
// 1. IMPORT CORRIGIDO: Aponta para o novo modelo de domínio
import 'package:techjobs/modules/candidato/model/notification_model.dart';
import 'package:techjobs/modules/empresa/model/company_connection_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Mock injetado diretamente para o desenvolvimento da UI.
  static const List<CompanyConnectionModel> _mockConnections = [
    CompanyConnectionModel(
      candidateId: '1',
      candidateName: 'Lucas Richter',
      role: 'Desenvolvedor Flutter Pleno',
      matchedJobTitle: 'Desenvolvedor(a) Flutter Pleno',
      matchDate: 'Hoje',
      hasUnreadMessages: true,
    ),
    CompanyConnectionModel(
      candidateId: '2',
      candidateName: 'Beatriz Soares',
      role: 'Dev Mobile iOS Senior',
      matchedJobTitle: 'Tech Lead Mobile',
      matchDate: 'Ontem',
      hasUnreadMessages: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: const CustomAppBar(
        // Ajustado para CustomAppBar (ou CustomAppBar2 dependendo de como você nomeou no seu core)
        title: 'Notificações',
        showProfileAvatar: false,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: _mockConnections.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _mockConnections.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                  indent: 72,
                  endIndent: 20,
                ),
                itemBuilder: (context, index) {
                  return _buildMinimalistConnection(_mockConnections[index]);
                },
              ),
      ),
    );
  }

  Widget _buildMinimalistConnection(CompanyConnectionModel connection) {
    final isUnread = connection.hasUnreadMessages;

    return InkWell(
      onTap: () {
        // 2. CONVERSÃO ATUALIZADA: Usamos o NotificationModel real
        final adaptedItem = NotificationModel(
          id: connection.candidateId,
          title: 'Conexão: ${connection.candidateName}',
          message: 'Vaga: ${connection.matchedJobTitle} • ${connection.role}',
          isRead: !isUnread, // Inverte a lógica (se tem unread, isRead é false)
          createdAt:
              DateTime.now(), // Data mockada para exibir na tela de detalhes
        );

        Modular.to.pushNamed('./notification-details', arguments: adaptedItem);
      },
      child: Container(
        color: isUnread
            ? AppColors.primary.withValues(alpha: 0.02)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isUnread
                  ? AppColors.secondary.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
              child: Text(
                connection.candidateName.substring(0, 2).toUpperCase(),
                style: GoogleFonts.montserrat(
                  color: isUnread ? AppColors.secondary : Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          connection.candidateName,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isUnread
                                ? AppColors.textTitle
                                : Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        connection.matchDate,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Vaga: ${connection.matchedJobTitle} • ${connection.role}',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: isUnread
                          ? Colors.grey.shade700
                          : Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Sem conexões ainda',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continue avaliando candidatos no feed.',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
