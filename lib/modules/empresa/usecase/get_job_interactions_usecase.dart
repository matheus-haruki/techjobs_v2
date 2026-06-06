import 'package:techjobs/modules/empresa/model/interaction_model.dart';
import 'package:techjobs/modules/empresa/repository/interaction_repository.dart';

abstract class IGetJobInteractionsUseCase {
  Future<List<InteractionModel>> call(String jobId);
}

class GetJobInteractionsUseCase implements IGetJobInteractionsUseCase {
  final IInteractionRepository _repository;

  const GetJobInteractionsUseCase(this._repository);

  @override
  Future<List<InteractionModel>> call(String jobId) async {
    if (jobId.isEmpty) throw ArgumentError('ID da vaga é obrigatório.');
    return await _repository.getInteractionsByJob(jobId);
  }
}