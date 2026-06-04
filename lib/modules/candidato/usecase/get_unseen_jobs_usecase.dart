import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/repository/job_repository.dart';

abstract class IGetUnseenJobsUseCase {
  Future<List<JobModel>> call(String candidateId);
}

class GetUnseenJobsUseCase implements IGetUnseenJobsUseCase {
  final IJobRepository _repository;

  const GetUnseenJobsUseCase(this._repository);

  @override
  Future<List<JobModel>> call(String candidateId) async {
    if (candidateId.isEmpty) {
      throw Exception('ID do candidato é obrigatório para buscar vagas.');
    }
    
    // Aqui no futuro poderíamos adicionar mais lógicas de negócio antes de ir ao banco,
    // como verificar se o candidato preencheu o perfil mínimo necessário.
    
    return await _repository.getUnseenJobs(candidateId);
  }
}