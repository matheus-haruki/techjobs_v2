import 'package:techjobs/modules/candidato/model/notification_model.dart';
import 'package:techjobs/modules/candidato/repository/notification_repository.dart';

abstract interface class IGetNotificationsUseCase {
  Future<List<NotificationModel>> call(String candidateId);
}

class GetNotificationsUseCase implements IGetNotificationsUseCase {
  final INotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  @override
  Future<List<NotificationModel>> call(String candidateId) async {
    if (candidateId.isEmpty) {
      throw ArgumentError('O ID do candidato não pode ser vazio.');
    }
    return await _repository.getNotifications(candidateId);
  }
}