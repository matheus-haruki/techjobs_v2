import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/empresa/model/notification_model.dart';

abstract interface class INotificationRepository {
  Future<List<NotificationModel>> getNotifications(String companyId);
  Future<void> markAsRead(String notificationId);
}

class NotificationRepositorySupabase implements INotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<NotificationModel>> getNotifications(String companyId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('company_id', companyId) // Filtramos especificamente pelas notificações desta empresa
          .order('created_at', ascending: false);

      return response.map((map) => NotificationModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Falha ao buscar notificações da empresa: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Falha ao atualizar notificação: $e');
    }
  }
}