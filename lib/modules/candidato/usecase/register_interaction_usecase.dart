import 'package:techjobs/modules/candidato/model/interaction_model.dart';
import 'package:techjobs/modules/candidato/repository/interaction_repository.dart';

abstract class IRegisterInteractionUseCase {
  Future<void> call(InteractionModel interaction);
}

class RegisterInteractionUseCase implements IRegisterInteractionUseCase {
  final IInteractionRepository _repository;

  const RegisterInteractionUseCase(this._repository);

  @override
  Future<void> call(InteractionModel interaction) async {
    if (interaction.candidateId.isEmpty || interaction.jobId.isEmpty) {
      throw Exception('ID do candidato e da vaga são obrigatórios.');
    }

    // A validação de domínio garante que o status unseen não seja inserido como uma ação ativa do usuário
    if (interaction.status == InteractionStatus.unseen) {
      throw Exception('Status de interação inválido para registro.');
    }

    await _repository.registerInteraction(interaction);
  }
}