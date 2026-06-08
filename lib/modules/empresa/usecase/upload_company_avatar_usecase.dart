import 'dart:io';
import 'package:techjobs/modules/empresa/repository/company_repository.dart';

abstract class IUploadCompanyAvatarUseCase {
  Future<String> call(String companyId, File image);
}

class UploadCompanyAvatarUseCase implements IUploadCompanyAvatarUseCase {
  final ICompanyRepository _repository;

  const UploadCompanyAvatarUseCase(this._repository);

  @override
  Future<String> call(String companyId, File image) async {
    // Validação básica para garantir que o ficheiro físico existe antes de fazer a chamada ao banco
    if (!image.existsSync()) {
      throw Exception('O arquivo de imagem não foi encontrado no dispositivo.');
    }
    
    // Delega a responsabilidade do upload físico para o repositório
    return await _repository.uploadAvatar(companyId, image);
  }
}