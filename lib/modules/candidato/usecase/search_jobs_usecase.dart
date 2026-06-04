import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/repository/job_repository.dart';

abstract class ISearchJobsUseCase {
  Future<List<JobModel>> call({
    required String candidateId,
    String? keyword,
    WorkModel? workModelFilter,
  });
}

class SearchJobsUseCase implements ISearchJobsUseCase {
  final IJobRepository _repository;

  const SearchJobsUseCase(this._repository);

  @override
  Future<List<JobModel>> call({
    required String candidateId,
    String? keyword,
    WorkModel? workModelFilter,
  }) async {
    if (candidateId.isEmpty) {
      throw Exception('ID do candidato é obrigatório para buscar vagas.');
    }

    // Delega a execução da busca para o repositório
    return await _repository.searchJobs(
      candidateId: candidateId,
      keyword: keyword,
      workModelFilter: workModelFilter,
    );
  }
}