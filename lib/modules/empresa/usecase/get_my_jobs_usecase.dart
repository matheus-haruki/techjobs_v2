import 'package:techjobs/modules/empresa/model/job_model.dart';
import 'package:techjobs/modules/empresa/repository/job_repository.dart';

abstract class IGetMyJobsUseCase {
  Future<List<JobModel>> call(String companyId);
}

class GetMyJobsUseCase implements IGetMyJobsUseCase {
  final IJobRepository _repository;

  const GetMyJobsUseCase(this._repository);

  @override
  Future<List<JobModel>> call(String companyId) async {
    if (companyId.trim().isEmpty) {
      throw Exception('ID da empresa inválido.');
    }

    return await _repository.getJobsByCompanyId(companyId);
  }
}
