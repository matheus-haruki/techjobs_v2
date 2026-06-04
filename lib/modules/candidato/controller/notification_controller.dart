import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/notification_model.dart';
import 'package:techjobs/modules/candidato/usecase/get_notifications_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/mark_notification_as_read_usecase.dart';

class NotificationController extends ValueNotifier<AppState<List<NotificationModel>>> {
  final IGetNotificationsUseCase _getNotificationsUseCase;
  final IMarkNotificationAsReadUseCase _markNotificationAsReadUseCase;

  NotificationController(
    this._getNotificationsUseCase,
    this._markNotificationAsReadUseCase,
  ) : super(InitialState<List<NotificationModel>>());

  Future<void> loadNotifications(String candidateId) async {
    value = LoadingState<List<NotificationModel>>();

    try {
      final notifications = await _getNotificationsUseCase(candidateId);
      value = SuccessState<List<NotificationModel>>(notifications);
    } catch (e) {
      value = ErrorState<List<NotificationModel>>(e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    // Preservamos o estado atual. Se não for sucesso, ignoramos a mutação local.
    if (value is! SuccessState<List<NotificationModel>>) return;

    final currentState = value as SuccessState<List<NotificationModel>>;
    final currentList = currentState.data;

    try {
      // Executa a mutação remota (Supabase)
      await _markNotificationAsReadUseCase(notificationId);

      // Mutação Otimista Local: Atualiza apenas o item específico na memória
      // Evita uma nova requisição O(n) ao banco de dados para buscar a lista inteira novamente
      final updatedList = currentList.map((notif) {
        if (notif.id == notificationId) {
          return NotificationModel(
            id: notif.id,
            title: notif.title,
            message: notif.message,
            isRead: true, // Atualizamos o status localmente
            createdAt: notif.createdAt,
            jobId: notif.jobId,
          );
        }
        return notif;
      }).toList();

      // Dispara o ValueNotifier para reconstruir a UI com a lista atualizada
      value = SuccessState<List<NotificationModel>>(updatedList);
    } catch (e) {
      debugPrint('Falha ao marcar notificação como lida: $e');
      // Em caso de erro na rede, não alteramos o estado visual para não mentir ao usuário.
    }
  }
}