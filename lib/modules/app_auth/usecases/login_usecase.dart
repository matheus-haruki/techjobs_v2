import 'package:techjobs/modules/app_auth/model/user_model.dart';
import 'package:techjobs/modules/app_auth/repository/auth_repository.dart';

abstract class ILoginUseCase {
  Future<UserModel> call(String email, String password);
}

class LoginUseCase implements ILoginUseCase {
  final IAuthRepository _repository;

  // Recebe o contrato do repositório, não a implementação direta.
  // Isso facilita a troca do Mock para a API no futuro.
  LoginUseCase(this._repository);

  @override
  Future<UserModel> call(String email, String password) async {
    // Validações locais (Regra de Negócio)
    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Por favor, insira um e-mail válido.');
    }

    if (password.trim().isEmpty) {
      throw Exception('A senha não pode estar vazia.');
    }

    if (password.length < 6) {
      throw Exception('A senha deve conter no mínimo 6 caracteres.');
    }

    // Se passou pelas validações, chama o repositório
    return await _repository.login(email, password);
  }
}
