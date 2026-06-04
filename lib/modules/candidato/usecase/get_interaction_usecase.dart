import 'package:techjobs/modules/candidato/model/interaction_model.dart';
import 'package:techjobs/modules/candidato/repository/interaction_repository.dart';

abstract class IGetInteractionUseCase {
  Future<InteractionModel?> call(String candidateId, String jobId);
}

class GetInteractionUseCase implements IGetInteractionUseCase {
  final IInteractionRepository _repository;

  const GetInteractionUseCase(this._repository);

  @override
  Future<InteractionModel?> call(String candidateId, String jobId) async {
    if (candidateId.isEmpty || jobId.isEmpty) {
      throw Exception('IDs inválidos para buscar interação.');
    }
    return await _repository.getInteraction(candidateId, jobId);
  }
}