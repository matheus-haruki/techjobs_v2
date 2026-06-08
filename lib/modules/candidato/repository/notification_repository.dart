import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/modules/candidato/model/notification_model.dart';

abstract interface class INotificationRepository {
  Future<List<NotificationModel>> getNotifications(String candidateId);
  Future<void> markAsRead(String notificationId);
}

class NotificationRepositorySupabase implements INotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<NotificationModel>> getNotifications(String candidateId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('candidate_id', candidateId)
        .order('created_at', ascending: false);

    return response.map((map) => NotificationModel.fromMap(map)).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }
}