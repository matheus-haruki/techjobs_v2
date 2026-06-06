import 'package:flutter_modular/flutter_modular.dart';

// --- MODELS ---
import 'package:techjobs/modules/empresa/model/notification_model.dart';

// --- CONTROLLERS ---
import 'package:techjobs/modules/empresa/controller/notification_controller.dart';
import 'package:techjobs/modules/empresa/controller/candidate_details_controller.dart';
import 'package:techjobs/modules/empresa/controller/company_profile_controller.dart';
import 'package:techjobs/modules/empresa/controller/manage_job_controller.dart';
import 'package:techjobs/modules/empresa/controller/my_jobs_controller.dart';
import 'package:techjobs/modules/empresa/controller/talent_feed_controller.dart';

// --- REPOSITORIES ---
import 'package:techjobs/modules/empresa/repository/company_repository.dart';
import 'package:techjobs/modules/empresa/repository/interaction_repository.dart';
import 'package:techjobs/modules/empresa/repository/job_repository.dart';
import 'package:techjobs/modules/empresa/repository/match_repository.dart';
import 'package:techjobs/modules/empresa/repository/talent_repository.dart';
import 'package:techjobs/modules/empresa/repository/notification_repository.dart';

// --- USECASES ---
import 'package:techjobs/modules/empresa/usecase/create_job_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_company_profile_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_job_interactions_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_my_jobs_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_notifications_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_talents_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/register_interaction_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/save_company_profile_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/upload_company_avatar_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/mark_notification_as_read_usecase.dart';

// --- PAGES (Menu Inferior) ---
import 'package:techjobs/modules/empresa/view/pages/company_base_page.dart';
import 'package:techjobs/modules/empresa/view/pages/edit_company_profile_page.dart';
import 'package:techjobs/modules/empresa/view/pages/talent_feed_page.dart';
import 'package:techjobs/modules/empresa/view/pages/my_jobs_page.dart';
import 'package:techjobs/modules/empresa/view/pages/notifications_page.dart';
import 'package:techjobs/modules/empresa/view/pages/company_profile_page.dart';

// --- PAGES (Full Screen) ---
import 'package:techjobs/modules/empresa/view/pages/candidate_details_page.dart';
import 'package:techjobs/modules/empresa/view/pages/create_job_page.dart';
import 'package:techjobs/modules/empresa/view/pages/manage_job_page.dart';
import 'package:techjobs/modules/empresa/view/pages/notification_details_page.dart';

class CompanyModule extends Module {
  @override
  void binds(Injector i) {
    // Repositories
    i.add<ICompanyRepository>(CompanyRepositorySupabase.new);
    i.add<IJobRepository>(JobRepositorySupabase.new);
    i.add<ITalentRepository>(TalentRepositorySupabase.new);
    i.add<IInteractionRepository>(InteractionRepositorySupabase.new);
    i.add<IMatchRepository>(MatchRepositorySupabase.new);
    i.add<INotificationRepository>(NotificationRepositorySupabase.new);

    // UseCases
    i.add<ISaveCompanyProfileUseCase>(SaveCompanyProfileUseCase.new);
    i.add<IGetCompanyProfileUseCase>(GetCompanyProfileUseCase.new);
    i.add<IUploadCompanyAvatarUseCase>(UploadCompanyAvatarUseCase.new);
    i.add<ICreateJobUseCase>(CreateJobUseCase.new);
    i.add<IGetMyJobsUseCase>(GetMyJobsUseCase.new);
    i.add<IGetTalentsUseCase>(GetTalentsUseCase.new);
    i.add<IRegisterInteractionUseCase>(RegisterInteractionUseCase.new);
    i.add<IGetJobInteractionsUseCase>(GetJobInteractionsUseCase.new);
    i.add<IGetNotificationsUseCase>(GetNotificationsUseCase.new);
    i.add<IMarkNotificationAsReadUseCase>(MarkNotificationAsReadUseCase.new);

    // Controllers
    i.addLazySingleton(CompanyProfileController.new);
    i.addLazySingleton(MyJobsController.new);
    i.addLazySingleton(TalentFeedController.new);
    i.addLazySingleton(ManageJobController.new);
    i.add(CandidateDetailsController.new);
    i.addLazySingleton(NotificationController.new);
  }

  @override
  void routes(RouteManager r) {
    // 1. Rota raiz contendo o roteamento aninhado (RouterOutlet)
    r.child(
      '/',
      child: (context) => const CompanyBasePage(),
      children: [
        ChildRoute(
          '/talents',
          child: (context) => const TalentFeedPage(),
          transition: TransitionType.noTransition,
        ),
        ChildRoute(
          '/jobs',
          child: (context) => const MyJobsPage(),
          transition: TransitionType.noTransition,
        ),
        ChildRoute(
          '/notifications',
          child: (context) => const NotificationsPage(),
          transition: TransitionType.noTransition,
        ),
        ChildRoute(
          '/profile',
          child: (context) => const CompanyProfilePage(),
          transition: TransitionType.noTransition,
        ),
      ],
    );

    // 2. Rotas independentes (Sobrepõem o menu inferior)
    r.child(
      '/candidate-details',
      child: (context) => CandidateDetailsPage(
        candidateId: r.args.data['candidateId'],
        jobId: r.args.data['jobId'],
        isReadOnly: r.args.data['isReadOnly'] ?? false,
      ),
    );

    r.child('/create-job', child: (context) => const CreateJobPage());

    r.child('/manage-job', child: (context) => ManageJobPage(job: r.args.data));

    r.child(
      '/edit-profile',
      child: (context) => EditCompanyProfilePage(
        // Extrai o Map caso exista (vem da RegisterPage), ou null (vem do menu do app)
        initialData: r.args.data as Map<String, dynamic>?,
      ),
    );

    // ROTA DE DETALHES DE NOTIFICAÇÃO ATIVADA
    r.child(
      '/notification-details',
      child: (context) {
        final notification = r.args.data as NotificationModel;
        return NotificationDetailsPage(notification: notification);
      },
    );
  }
}
