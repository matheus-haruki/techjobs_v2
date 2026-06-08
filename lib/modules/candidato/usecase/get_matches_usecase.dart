import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/repository/job_repository.dart';

abstract class IGetMatchesUseCase {
  Future<List<JobModel>> call(String candidateId);
}

class GetMatchesUseCase implements IGetMatchesUseCase {
  final IJobRepository _repository;

  const GetMatchesUseCase(this._repository);

  @override
  Future<List<JobModel>> call(String candidateId) async {
    if (candidateId.isEmpty) {
      throw Exception('ID do candidato é obrigatório para buscar conexões.');
    }

    return await _repository.getMatches(candidateId);
  }
}