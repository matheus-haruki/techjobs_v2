import 'package:techjobs/modules/empresa/repository/notification_repository.dart';

abstract interface class IMarkNotificationAsReadUseCase {
  Future<void> call(String notificationId);
}

class MarkNotificationAsReadUseCase implements IMarkNotificationAsReadUseCase {
  final INotificationRepository _repository;

  MarkNotificationAsReadUseCase(this._repository);

  @override
  Future<void> call(String notificationId) async {
    if (notificationId.isEmpty) {
      throw ArgumentError('O ID da notificação não pode ser vazio.');
    }
    await _repository.markAsRead(notificationId);
  }
}