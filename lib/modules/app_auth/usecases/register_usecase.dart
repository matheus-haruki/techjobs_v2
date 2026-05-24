import 'package:techjobs/modules/app_auth/model/user_model.dart';
import 'package:techjobs/modules/app_auth/repository/auth_repository.dart';

abstract class IRegisterUseCase {
  Future<UserModel> call({
    required String name,
    required String email,
    required String password,
    required String role,
  });
}

class RegisterUseCase implements IRegisterUseCase {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<UserModel> call({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // Validações locais (Regra de Negócio)
    if (name.trim().isEmpty) {
      throw Exception('O nome é obrigatório.');
    }

    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Por favor, insira um e-mail válido.');
    }

    if (password.length < 6) {
      throw Exception('Sua senha deve ter no mínimo 6 caracteres.');
    }

    if (role != 'candidato' && role != 'empresa') {
      throw Exception('Tipo de perfil inválido. Escolha Candidato ou Empresa.');
    }

    // Passou nas validações, envia para o repositório cadastrar
    return await _repository.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}