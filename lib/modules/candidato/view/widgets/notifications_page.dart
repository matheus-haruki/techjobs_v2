import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';

class NotificationItem {
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final bool isUnread;

  NotificationItem({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    this.isUnread = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Entrevista Agendada!',
      description:
          'Sua entrevista com a TechCorp S/A foi confirmada para amanhã às 10:00. O link foi enviado por e-mail.',
      timeAgo: 'Agora',
      icon: Icons.video_camera_front_rounded,
      iconColor: Colors.blueAccent,
      isUnread: true,
    ),
    NotificationItem(
      title: 'Novo Match 🎉',
      description:
          'Fintech Bank também curtiu o seu perfil. Envie uma mensagem para iniciar a conversa!',
      timeAgo: '2 h',
      icon: Icons.favorite_rounded,
      iconColor: Colors.green,
      isUnread: true,
    ),
    NotificationItem(
      title: 'Currículo Visualizado',
      description:
          'A empresa StartupX visualizou o seu currículo para a vaga de Dev Mobile Júnior.',
      timeAgo: 'Ontem',
      icon: Icons.remove_red_eye_rounded,
      iconColor: AppColors.secondary,
      isUnread: false,
    ),
    NotificationItem(
      title: 'Candidatura Finalizada',
      description:
          'Infelizmente a empresa AppleBR decidiu seguir com outros candidatos. Não desanime!',
      timeAgo: '3 d',
      icon: Icons.cancel_rounded,
      iconColor: Colors.redAccent,
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: const CustomAppBar(title: 'Notificações'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _notifications.length,
          // Divisória minimalista e fina entre os itens
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey.shade200,
            indent:
                72, // Alinha a linha divisória com o texto, ignorando o ícone
            endIndent: 20,
          ),
          itemBuilder: (context, index) {
            final item = _notifications[index];
            return _buildMinimalistNotification(item);
          },
        ),
      ),
    );
  }

  Widget _buildMinimalistNotification(NotificationItem item) {
    return InkWell(
      onTap: () {
        // Envia o usuário para a tela de detalhes, passando o objeto 'item'
        Modular.to.pushNamed('./notification-details', arguments: item);
      },
      child: Container(
        // Fundo levemente colorido APENAS se não estiver lido
        color: item.isUnread
            ? AppColors.primary.withValues(alpha:0.02)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone sem fundo (Fica cinza se a notificação já foi lida)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                item.icon,
                size: 24,
                color: item.isUnread ? item.iconColor : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 16),

            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha do Título e Tempo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            // Título perde o peso se já foi lido
                            fontWeight: item.isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: item.isUnread
                                ? AppColors.textTitle
                                : Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tempo movido para cima
                      Text(
                        item.timeAgo,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      // Bolinha indicadora
                      if (item.isUnread) ...[
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

                  // Descrição
                  Text(
                    item.description,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: item.isUnread
                          ? Colors.grey.shade700
                          : Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines:
                        2, // Limita a duas linhas para manter o minimalismo na listagem
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
}
