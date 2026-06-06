import 'package:techjobs/modules/empresa/model/interaction_model.dart';
import 'package:techjobs/modules/empresa/repository/interaction_repository.dart';

abstract class IRegisterInteractionUseCase {
  Future<void> call({
    required String candidateId,
    required String jobId,
    required InteractionStatus status, // Status original do Swipe na UI
  });
}

class RegisterInteractionUseCase implements IRegisterInteractionUseCase {
  final IInteractionRepository _repository;

  const RegisterInteractionUseCase(this._repository);

  @override
  Future<void> call({
    required String candidateId,
    required String jobId,
    required InteractionStatus status,
  }) async {
    // 1. Pergunta ao banco: Esse candidato já interagiu com a vaga?
    final existingInteraction = await _repository.getInteraction(candidateId, jobId);

    InteractionStatus finalStatus;

    // 2. Máquina de Estados
    if (status == InteractionStatus.like) {
      // Se a empresa deu LIKE e o candidato também já tinha dado LIKE...
      if (existingInteraction != null && existingInteraction.status == InteractionStatus.like) {
        finalStatus = InteractionStatus.match; // 🎉 DEU MATCH!
      } else {
        finalStatus = InteractionStatus.company_like; // Só a empresa curtiu por enquanto
      }
    } else {
      finalStatus = InteractionStatus.company_dislike; // Empresa descartou
    }

    // 3. Salva a decisão final
    final interaction = InteractionModel(
      candidateId: candidateId,
      jobId: jobId,
      status: finalStatus,
    );

    await _repository.registerInteraction(interaction);
  }
}