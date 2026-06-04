import 'package:techjobs/modules/empresa/model/company_model.dart';
import 'package:techjobs/modules/empresa/repository/company_repository.dart';

abstract class ISaveCompanyProfileUseCase {
  Future<void> call(CompanyModel company);
}

class SaveCompanyProfileUseCase implements ISaveCompanyProfileUseCase {
  final ICompanyRepository _repository;

  SaveCompanyProfileUseCase(this._repository);

  @override
  Future<void> call(CompanyModel company) async {
    // Regra de Negócio da Empresa
    if (company.name.trim().isEmpty) {
      throw Exception('O nome da empresa é obrigatório.');
    }

    // Se a empresa enviou um CNPJ, valida se não está vazio só com espaços
    if (company.cnpj != null && company.cnpj!.trim().isEmpty) {
      throw Exception('O CNPJ não pode ser vazio.');
    }

    // Manda para o repositório salvar
    await _repository.saveProfile(company);
  }
}
