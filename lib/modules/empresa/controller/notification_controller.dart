import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/empresa/model/notification_model.dart';
import 'package:techjobs/modules/empresa/usecase/get_notifications_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/mark_notification_as_read_usecase.dart';

class NotificationController extends ValueNotifier<AppState<List<NotificationModel>>> {
  final IGetNotificationsUseCase _getNotificationsUseCase;
  final IMarkNotificationAsReadUseCase _markNotificationAsReadUseCase;

  NotificationController(
    this._getNotificationsUseCase,
    this._markNotificationAsReadUseCase,
  ) : super(InitialState<List<NotificationModel>>());

  Future<void> loadNotifications(String companyId) async {
    value = LoadingState<List<NotificationModel>>();

    try {
      final notifications = await _getNotificationsUseCase.call(companyId);
      value = SuccessState<List<NotificationModel>>(notifications);
    } catch (e) {
      value = ErrorState<List<NotificationModel>>(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    // Se não estivermos no estado de sucesso (com uma lista carregada), não fazemos nada.
    if (value is! SuccessState<List<NotificationModel>>) return;

    final currentState = value as SuccessState<List<NotificationModel>>;
    final currentList = currentState.data;

    try {
      // 1. Executa a mutação no banco de dados
      await _markNotificationAsReadUseCase.call(notificationId);

      // 2. Mutação Otimista Local: Atualiza apenas o item específico na memória
      final updatedList = currentList.map((notif) {
        if (notif.id == notificationId) {
          return NotificationModel(
            id: notif.id,
            title: notif.title,
            message: notif.message,
            isRead: true, // Alteramos o status localmente para refletir na UI instantaneamente
            createdAt: notif.createdAt,
            jobId: notif.jobId,
          );
        }
        return notif;
      }).toList();

      // 3. Emite o novo estado para a View se reconstruir
      value = SuccessState<List<NotificationModel>>(updatedList);
    } catch (e) {
      debugPrint('Falha ao marcar notificação como lida: $e');
      // Em caso de falha silenciosa de rede, não corrompemos a UI.
    }
  }
}