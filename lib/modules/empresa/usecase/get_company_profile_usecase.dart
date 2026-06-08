import 'package:techjobs/modules/empresa/model/company_model.dart';
import 'package:techjobs/modules/empresa/repository/company_repository.dart';

abstract class IGetCompanyProfileUseCase {
  Future<CompanyModel?> call(String id);
}

class GetCompanyProfileUseCase implements IGetCompanyProfileUseCase {
  final ICompanyRepository _repository;

  const GetCompanyProfileUseCase(this._repository);

  @override
  Future<CompanyModel?> call(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID da empresa é inválido.');
    }

    return await _repository.getProfile(id);
  }
}