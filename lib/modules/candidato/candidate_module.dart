import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/modules/candidato/controller/candidate_controller.dart';
import 'package:techjobs/modules/candidato/controller/candidate_profile_controller.dart';
import 'package:techjobs/modules/candidato/controller/chat_controller.dart';
import 'package:techjobs/modules/candidato/controller/company_details_controller.dart';
import 'package:techjobs/modules/candidato/controller/connections_controller.dart';
import 'package:techjobs/modules/candidato/controller/feed_controller.dart';
import 'package:techjobs/modules/candidato/controller/notification_controller.dart';
import 'package:techjobs/modules/candidato/controller/search_controller.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';
import 'package:techjobs/modules/candidato/repository/candidate_repository.dart';
import 'package:techjobs/modules/candidato/repository/company_repository.dart';
import 'package:techjobs/modules/candidato/repository/interaction_repository.dart';
import 'package:techjobs/modules/candidato/repository/job_repository.dart';
import 'package:techjobs/modules/candidato/repository/notification_repository.dart';
import 'package:techjobs/modules/candidato/usecase/get_candidate_profile_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/get_company_jobs_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/get_company_profile_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/get_interaction_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/get_matches_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/get_notifications_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/get_unseen_jobs_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/mark_notification_as_read_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/register_interaction_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/save_candidate_profile_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/schedule_interview_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/search_jobs_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/upload_candidate_avatar_usecase.dart';
import 'package:techjobs/modules/candidato/view/base_candidate_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/chat_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/company_details_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/edit_profile_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/job_details_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/notification_details_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/profile_page.dart';

class CandidateModule extends Module {
  @override
  void binds(Injector i) {
    // 1. Injeta o Repositório do Supabase
    i.add<ICandidateRepository>(CandidateRepositorySupabase.new);
    i.add<IJobRepository>(JobRepositorySupabase.new);
    i.add<IInteractionRepository>(InteractionRepositorySupabase.new);
    i.add<INotificationRepository>(NotificationRepositorySupabase.new);
    i.add<ICompanyRepository>(CompanyRepositorySupabase.new);

    // 2. Injeta os Casos de Usos
    i.add<ISaveCandidateProfileUseCase>(SaveCandidateProfileUseCase.new);
    i.add<IGetCandidateProfileUseCase>(GetCandidateProfileUseCase.new);
    i.add<IUploadCandidateAvatarUseCase>(UploadCandidateAvatarUseCase.new);
    i.add<IGetUnseenJobsUseCase>(GetUnseenJobsUseCase.new);
    i.add<IRegisterInteractionUseCase>(RegisterInteractionUseCase.new);
    i.add<ISearchJobsUseCase>(SearchJobsUseCase.new);
    i.add<IGetMatchesUseCase>(GetMatchesUseCase.new);
    i.add<IGetInteractionUseCase>(GetInteractionUseCase.new);
    i.add<IScheduleInterviewUseCase>(ScheduleInterviewUseCase.new);
    i.add<IGetNotificationsUseCase>(GetNotificationsUseCase.new);
    i.add<IMarkNotificationAsReadUseCase>(MarkNotificationAsReadUseCase.new);
    i.add<IGetCompanyProfileUseCase>(GetCompanyProfileUseCase.new);
    i.add<IGetCompanyJobsUseCase>(GetCompanyJobsUseCase.new);

    // 3. O seu Controller (que logo vai receber o UseCase como dependência)
    i.addLazySingleton(CandidateController.new);
    i.addLazySingleton(CandidateProfileController.new);
    i.addLazySingleton(FeedController.new);
    i.addLazySingleton(SearchController.new);
    i.addLazySingleton(ConnectionsController.new);
    i.addLazySingleton(ChatController.new);
    i.addLazySingleton<NotificationController>(NotificationController.new);
    i.add(CompanyDetailsController.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const BaseCandidatePage());
    r.child('/profile', child: (context) => const ProfilePage());
    r.child('/chat', child: (context) => ChatPage(job: r.args.data));
    r.child(
      '/notification-details',
      child: (context) => NotificationDetailsPage(notification: r.args.data),
    );

    r.child(
      '/job-details',
      child: (context) => JobDetailsPage(job: r.args.data),
    );
    r.child(
      '/edit-profile',
      // Cast explícito para garantir a tipagem do Modular
      child: (context) =>
          EditProfilePage(candidate: r.args.data as CandidateModel),
    );

    r.child(
      '/company-details',
      child: (context) => CompanyDetailsPage(companyId: r.args.data as String),
    );
  }
}
