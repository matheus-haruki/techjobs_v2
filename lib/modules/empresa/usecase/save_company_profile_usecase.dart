import 'package:techjobs/modules/empresa/model/company_model.dart';
import 'package:techjobs/modules/empresa/repository/company_repository.dart';

abstract class ISaveCompanyProfileUseCase {
  Future<void> call(CompanyModel company);
}

class SaveCompanyProfileUseCase implements ISaveCompanyProfileUseCase {
  final ICompanyRepository _repository;

  const SaveCompanyProfileUseCase(this._repository);

  @override
  Future<void> call(CompanyModel company) async {
    // Validação de regra de negócio (Domain Layer)
    if (company.name.trim().isEmpty) {
      throw Exception('O nome da empresa não pode estar vazio.');
    }

    if (company.cnpj != null && company.cnpj!.trim().isEmpty) {
       throw Exception('O CNPJ não pode ser apenas espaços em branco.');
    }

    await _repository.saveProfile(company);
  }
}