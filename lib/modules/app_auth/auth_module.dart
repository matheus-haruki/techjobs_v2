import 'package:flutter_modular/flutter_modular.dart';

import 'controller/auth_controller.dart';
import 'repository/auth_repository.dart'; // Aqui dentro agora vive o AuthRepositorySupabase
import 'usecases/login_usecase.dart';
import 'usecases/register_usecase.dart';
import 'view/login_page.dart';
import 'view/register_page.dart';

class AuthModule extends Module {
  @override
  void binds(Injector i) {
    // 1. A MÁGICA ACONTECE AQUI: Trocamos o AuthRepositoryMock pelo AuthRepositorySupabase!
    i.add<IAuthRepository>(AuthRepositorySupabase.new);

    // 2. Injetamos os Casos de Uso
    i.add<ILoginUseCase>(LoginUseCase.new);
    i.add<IRegisterUseCase>(RegisterUseCase.new);

    // 3. Injetamos o Controller como Singleton.
    // Assim, se o usuário for para a tela de Cadastro e voltar para o Login,
    // usamos a mesma instância de gerenciamento de estado.
    i.addSingleton<AuthController>(AuthController.new);
  }

  @override
  void routes(RouteManager r) {
    // A rota base '/' deste módulo abrirá a LoginPage
    r.child('/', child: (context) => const LoginPage());

    // A rota '/register' abrirá a RegisterPage
    r.child('/register', child: (context) => const RegisterPage());
  }
}
