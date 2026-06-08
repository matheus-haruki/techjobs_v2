import 'package:techjobs/modules/candidato/model/company_model.dart';
import 'package:techjobs/modules/candidato/repository/company_repository.dart';

abstract interface class IGetCompanyProfileUseCase {
  Future<CompanyModel> call(String companyId);
}

class GetCompanyProfileUseCase implements IGetCompanyProfileUseCase {
  final ICompanyRepository _repository;

  GetCompanyProfileUseCase(this._repository);

  @override
  Future<CompanyModel> call(String companyId) async {
    if (companyId.trim().isEmpty) {
      throw Exception('ID da empresa inválido.');
    }
    return await _repository.getCompanyById(companyId);
  }
}