import 'dart:io';
import 'package:techjobs/modules/candidato/repository/candidate_repository.dart';

abstract class IUploadCandidateAvatarUseCase {
  Future<String> call({required String candidateId, required File imageFile});
}

class UploadCandidateAvatarUseCase implements IUploadCandidateAvatarUseCase {
  final ICandidateRepository _repository;

  const UploadCandidateAvatarUseCase(this._repository);

  @override
  Future<String> call({required String candidateId, required File imageFile}) async {
    if (candidateId.isEmpty) {
      throw Exception('ID do candidato inválido.');
    }
    
    // Aqui poderíamos injetar validações de tamanho de arquivo no futuro, 
    // mantendo a regra de negócio isolada da UI.
    
    return await _repository.uploadAvatar(candidateId: candidateId, imageFile: imageFile);
  }
}