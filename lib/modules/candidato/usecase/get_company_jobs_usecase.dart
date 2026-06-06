import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/repository/job_repository.dart';

abstract interface class IGetCompanyJobsUseCase {
  Future<List<JobModel>> call({
    required String companyId,
    required String candidateId,
  });
}

class GetCompanyJobsUseCase implements IGetCompanyJobsUseCase {
  final IJobRepository _repository;

  GetCompanyJobsUseCase(this._repository);

  @override
  Future<List<JobModel>> call({
    required String companyId,
    required String candidateId,
  }) async {
    if (companyId.trim().isEmpty) {
      throw Exception('ID da empresa inválido.');
    }
    
    if (candidateId.trim().isEmpty) {
      throw Exception('ID do candidato inválido.');
    }

    return await _repository.getJobsByCompanyId(
      companyId: companyId,
      candidateId: candidateId,
    );
  }
}