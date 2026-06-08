import 'package:techjobs/modules/empresa/model/talent_model.dart';
import 'package:techjobs/modules/empresa/repository/talent_repository.dart';

abstract class IGetTalentsUseCase {
  Future<List<TalentModel>> call();
}

class GetTalentsUseCase implements IGetTalentsUseCase {
  final ITalentRepository _repository;

  const GetTalentsUseCase(this._repository);

  @override
  Future<List<TalentModel>> call() async {
    // No futuro, se quisermos adicionar filtros (ex: buscar só devs Flutter), 
    // a regra de negócio entraria aqui. Por enquanto, trazemos todos!
    return await _repository.getAllTalents();
  }
}