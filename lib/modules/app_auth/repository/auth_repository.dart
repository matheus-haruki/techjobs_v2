import 'package:techjobs/modules/app_auth/model/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
}

// Esta é a implementação Mockada para você desenvolver a UI agora.
class AuthRepositoryMock implements IAuthRepository {
  @override
  Future<UserModel> login(String email, String password) async {
    // Simula o tempo de latência da internet
    await Future.delayed(const Duration(seconds: 2));

    // Simulando uma regra de erro que viria do backend
    if (email == 'erro@teste.com') {
      throw Exception('Credenciais inválidas. Tente novamente.');
    }

    // Retorna um usuário de mentira em caso de sucesso
    return UserModel(
      id: 'mock-123',
      name: 'Usuário Teste',
      email: email,
      role: 'candidato',
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Falha ao registrar no servidor.');
    }

    return UserModel(
      id: 'mock-999',
      name: name,
      email: email,
      role: role,
    );
  }
}