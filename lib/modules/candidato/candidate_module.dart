import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/modules/candidato/view/base_candidate_page.dart';

class CandidateModule extends Module {
  @override
  void binds(Injector i) {
    // Aqui injetaremos os futuros controllers e usecases do feed
  }

  @override
  void routes(RouteManager r) {
    // Rota inicial do módulo do candidato
    r.child('/', child: (context) => const BaseCandidatePage());
  }
}
