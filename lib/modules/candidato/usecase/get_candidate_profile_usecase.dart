import 'package:techjobs/modules/candidato/model/candidate_model.dart';
import 'package:techjobs/modules/candidato/repository/candidate_repository.dart';

abstract class IGetCandidateProfileUseCase {
  Future<CandidateModel> call(String id);
}

class GetCandidateProfileUseCase implements IGetCandidateProfileUseCase {
  final ICandidateRepository _repository;

  GetCandidateProfileUseCase(this._repository);

  @override
  Future<CandidateModel> call(String id) async {
    if (id.isEmpty) {
      throw Exception('ID do usuário não pode ser vazio ao buscar o perfil.');
    }

    return await _repository.getProfile(id);
  }
}
