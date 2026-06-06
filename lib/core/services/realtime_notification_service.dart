import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/components/in_app_notification.dart';

class RealtimeNotificationService {
  RealtimeChannel? _channel;

  void startListening(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) return;

    _channel = supabase.channel('public:notifications').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      callback: (payload) {
        final newRecord = payload.newRecord;
        
        final isForMe = newRecord['candidate_id'] == user.id || newRecord['company_id'] == user.id;

        if (isForMe) {
          InAppNotification.show(
            context: context,
            title: newRecord['title'] ?? 'Nova Notificação',
            message: newRecord['message'] ?? '',
          );
        }
      },
    ).subscribe();
  }

  void stopListening() {
    _channel?.unsubscribe();
  }
}