import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/modules/candidato/controller/cadidate_controller.dart';
import 'package:techjobs/modules/candidato/view/base_candidate_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/chat_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/edit_profile_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/job_details_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/notification_details_page.dart';

class CandidateModule extends Module {
  @override
  void binds(Injector i) {
    i.addLazySingleton(CandidateController.new);
  }

  @override
  void routes(RouteManager r) {
    // Rota inicial do módulo do candidato
    r.child('/', child: (context) => const BaseCandidatePage());
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
      child: (context) => EditProfilePage(profileData: r.args.data),
    );
  }
}
