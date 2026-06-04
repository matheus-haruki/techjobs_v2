import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/modules/candidato/view/widgets/notification_details_page.dart';
import 'package:techjobs/modules/empresa/repository/company_repository.dart';
import 'package:techjobs/modules/empresa/usecase/save_company_profile_usecase.dart';
import 'package:techjobs/modules/empresa/view/widgets/candidate_details_page.dart';
import 'package:techjobs/modules/empresa/view/widgets/create_job_page.dart';
import 'package:techjobs/modules/empresa/view/widgets/manage_job_page.dart';
import 'view/company_base_page.dart';

class CompanyModule extends Module {
  @override
  void binds(Injector i) {
    // 1. Injeta o Repositório do Supabase
    i.add<ICompanyRepository>(CompanyRepositorySupabase.new);
    
    // 2. Injeta o Caso de Uso
    i.add<ISaveCompanyProfileUseCase>(SaveCompanyProfileUseCase.new);
    
    // 3. Aqui entrará o CompanyController posteriormente
    // i.addLazySingleton(CompanyController.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const CompanyBasePage());

    r.child(
      '/candidate-details',
      child: (context) => CandidateDetailsPage(candidate: r.args.data),
    );

    r.child('/create-job', child: (context) => const CreateJobPage());

    r.child(
      '/notification-details',
      child: (context) => NotificationDetailsPage(notification: r.args.data),
    );

    r.child(
      '/manage-job',
      child: (context) => ManageJobPage(
        job: r.args.data, 
      ),
    );
  }
}