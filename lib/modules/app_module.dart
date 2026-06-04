import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/modules/app_auth/auth_module.dart';
import 'package:techjobs/modules/candidato/candidate_module.dart';
import 'package:techjobs/modules/empresa/company_module.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    // Redireciona tudo que iniciar no app para o módulo de Auth
    r.module('/', module: AuthModule());
    r.module('/candidate', module: CandidateModule());
    r.module('/company', module: CompanyModule());
  }
}