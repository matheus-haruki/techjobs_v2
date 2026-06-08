
import 'package:techjobs/modules/candidato/model/candidate_model.dart';
import 'package:techjobs/modules/candidato/repository/candidate_repository.dart';

abstract class ISaveCandidateProfileUseCase {
  Future<void> call(CandidateModel candidate);
}

class SaveCandidateProfileUseCase implements ISaveCandidateProfileUseCase {
  final ICandidateRepository _repository;

  SaveCandidateProfileUseCase(this._repository);

  @override
  Future<void> call(CandidateModel candidate) async {
    // Regra de Negócio: Não deixa salvar se o nome estiver vazio
    if (candidate.name.trim().isEmpty) {
      throw Exception('O nome do candidato é obrigatório.');
    }

    // Se passar pela validação, manda para o repositório salvar no banco
    await _repository.saveProfile(candidate);
  }
}