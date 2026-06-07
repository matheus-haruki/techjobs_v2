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
    // Validações iniciais de domínio
    if (interaction.candidateId.isEmpty || interaction.jobId.isEmpty) {
      throw Exception('ID do candidato e da vaga são obrigatórios.');
    }

    if (interaction.status == InteractionStatus.unseen) {
      throw Exception('Status de interação inválido para registro.');
    }

    // 1. Pergunta ao banco: A empresa já interagiu com esse candidato para esta vaga?
    final existingInteraction = await _repository.getInteraction(
      interaction.candidateId,
      interaction.jobId,
    );

    InteractionStatus finalStatus;

    // 2. Máquina de Estados (Espelho da Empresa)
    if (interaction.status == InteractionStatus.like) {
      // Se o Candidato deu LIKE e a Empresa já tinha dado LIKE (company_like)...
      if (existingInteraction != null && existingInteraction.status == InteractionStatus.company_like) {
        finalStatus = InteractionStatus.match; // 🎉 DEU MATCH!
      } else {
        finalStatus = InteractionStatus.like; // Só o candidato curtiu por enquanto
      }
    } else {
      finalStatus = InteractionStatus.dislike; // Candidato descartou a vaga
    }

    // 3. Monta o modelo final com o status resolvido, preservando id e createdAt originais
    final interactionToSave = InteractionModel(
      id: interaction.id,
      candidateId: interaction.candidateId,
      jobId: interaction.jobId,
      status: finalStatus,
      createdAt: interaction.createdAt,
    );

    // 4. Salva a decisão final corretamente no banco
    await _repository.registerInteraction(interactionToSave);
  }
}