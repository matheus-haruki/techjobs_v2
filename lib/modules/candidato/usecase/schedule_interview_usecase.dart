import 'package:techjobs/modules/candidato/repository/interaction_repository.dart';

abstract class IScheduleInterviewUseCase {
  Future<void> call(String candidateId, String jobId, DateTime date);
}

class ScheduleInterviewUseCase implements IScheduleInterviewUseCase {
  final IInteractionRepository _repository;

  const ScheduleInterviewUseCase(this._repository);

  @override
  Future<void> call(String candidateId, String jobId, DateTime date) async {
    if (candidateId.isEmpty || jobId.isEmpty) {
      throw Exception('IDs inválidos para agendar entrevista.');
    }
    await _repository.scheduleInterview(candidateId, jobId, date);
  }
}