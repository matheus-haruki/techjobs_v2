import 'package:techjobs/modules/empresa/repository/job_repository.dart';

abstract interface class IDeleteJobUseCase {
  Future<void> call(String jobId);
}

class DeleteJobUseCase implements IDeleteJobUseCase {
  final IJobRepository _repository;

  DeleteJobUseCase(this._repository);

  @override
  Future<void> call(String jobId) async {
    if (jobId.isEmpty) {
      throw ArgumentError('ID da vaga não pode ser vazio.');
    }
    await _repository.deleteJob(jobId);
  }
}