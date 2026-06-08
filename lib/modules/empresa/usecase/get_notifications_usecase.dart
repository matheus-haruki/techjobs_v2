import 'package:techjobs/modules/empresa/model/notification_model.dart';
import 'package:techjobs/modules/empresa/repository/notification_repository.dart';

abstract interface class IGetNotificationsUseCase {
  Future<List<NotificationModel>> call(String companyId);
}

class GetNotificationsUseCase implements IGetNotificationsUseCase {
  final INotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  @override
  Future<List<NotificationModel>> call(String companyId) async {
    if (companyId.isEmpty) {
      throw ArgumentError('O ID da empresa não pode ser vazio.');
    }
    return await _repository.getNotifications(companyId);
  }
}