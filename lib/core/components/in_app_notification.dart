import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum NotificationType { general, like, match }

class InAppNotification {
  /// Método estático para manter a compatibilidade com o `RealtimeNotificationService`
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    VoidCallback? onTap,
  }) {
    final expanded = ValueNotifier<bool>(false);

    void onVerticalDragEnd(DragEndDetails details) {
      if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
        // Deslizar para cima: fecha a notificação
        Navigator.of(context, rootNavigator: true).pop();
      } else if (details.primaryVelocity! > 0) {
        // Deslizar para baixo: expande a notificação
        expanded.value = true;
      }
    }

    Flushbar(
      messageText: GestureDetector(
        onVerticalDragEnd: onVerticalDragEnd,
        onLongPress: () => expanded.value = true,
        child: ValueListenableBuilder<bool>(
          valueListenable: expanded,
          builder: (context, isExpanded, child) {
            return _CustomNotificationContent(
              title: title,
              message: message,
              type: type,
              expanded: isExpanded,
            );
          },
        ),
      ),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      duration: const Duration(seconds: 10), // Aumentado para dar tempo de ler se for longo
      animationDuration: const Duration(milliseconds: 400),
      onTap: (_) {
        Navigator.of(context, rootNavigator: true).pop();
        onTap?.call();
      },
    ).show(context);
  }
}

class _CustomNotificationContent extends StatefulWidget {
  final String title;
  final String message;
  final NotificationType type;
  final bool expanded;

  const _CustomNotificationContent({
    required this.title,
    required this.message,
    required this.type,
    required this.expanded,
  });

  @override
  State<_CustomNotificationContent> createState() => _CustomNotificationContentState();
}

class _CustomNotificationContentState extends State<_CustomNotificationContent> with SingleTickerProviderStateMixin {
  Duration _getAnimationDuration() {
    final charCount = widget.message.length;
    if (charCount <= 100) return const Duration(milliseconds: 150);
    if (charCount <= 200) return const Duration(milliseconds: 250);
    return const Duration(milliseconds: 350);
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite_rounded;
      case NotificationType.match:
        return Icons.handshake_rounded;
      case NotificationType.general:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Colors.redAccent;
      case NotificationType.match:
        return Colors.blueAccent;
      case NotificationType.general:
        return const Color(0xFF5A92AA); // Cor principal do app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          // Detalhe visual de fundo (Substitui o SVG original para evitar quebra)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: 48,
              width: 80,
              decoration: BoxDecoration(
                color: _getIconColor(widget.type).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(40.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 12.0, top: 4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getIconColor(widget.type).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(widget.type),
                      color: _getIconColor(widget.type),
                      size: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      ClipRect(
                        child: AnimatedSize(
                          duration: _getAnimationDuration(),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: widget.expanded 
                                ? const BoxConstraints() 
                                : const BoxConstraints(maxHeight: 40), // Reduzido para forçar corte em textos normais
                            child: Text(
                              widget.message,
                              style: GoogleFonts.montserrat(
                                fontSize: 13.0,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                              maxLines: widget.expanded ? 20 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}