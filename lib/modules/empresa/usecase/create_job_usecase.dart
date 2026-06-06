import 'package:techjobs/modules/empresa/model/job_model.dart';
import 'package:techjobs/modules/empresa/repository/job_repository.dart';

abstract class ICreateJobUseCase {
  Future<void> call(JobModel job);
}

class CreateJobUseCase implements ICreateJobUseCase {
  final IJobRepository _repository;

  const CreateJobUseCase(this._repository);

  @override
  Future<void> call(JobModel job) async {
    // Validações de Domínio: A empresa não pode criar uma vaga em branco
    if (job.title.trim().isEmpty) {
      throw Exception('O título da vaga não pode estar vazio.');
    }
    if (job.description.trim().isEmpty) {
      throw Exception('A descrição da vaga é obrigatória.');
    }

    await _repository.createJob(job);
  }
}