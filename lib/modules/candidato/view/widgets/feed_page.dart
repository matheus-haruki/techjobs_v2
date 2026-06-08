import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/style/app_fonts.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/interaction_model.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/controller/feed_controller.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final CardSwiperController _swiperController = CardSwiperController();
  late final FeedController _feedController;

  @override
  void initState() {
    super.initState();
    // 1. Injeção de Dependência: Recupera a instância do Modular
    _feedController = Modular.get<FeedController>();

    // 2. Dispara a busca de vagas usando o ID do usuário autenticado no momento
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _feedController.loadJobs(userId);
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: const CustomAppBar(title: 'Feed de Vagas'),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        // 3. Padrão Observer: Escuta as mudanças de estado do Controller
        child: ValueListenableBuilder<AppState<List<JobModel>>>(
          valueListenable: _feedController,
          builder: (context, state, child) {
            // Verifica os estados explicitando o tipo genérico
            if (state is LoadingState<List<JobModel>> ||
                state is InitialState<List<JobModel>>) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is ErrorState<List<JobModel>>) {
              // Agora o Dart sabe que state é um ErrorState tipado e expõe a propriedade message
              return _buildErrorState(state.message);
            }

            if (state is SuccessState<List<JobModel>>) {
              // O compilador entende que state.data existe e é uma List<JobModel>
              final jobs = state.data;

              if (jobs.isEmpty) {
                return _buildEmptyState();
              }

              return _buildFeedContent(jobs);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFeedContent(List<JobModel> jobs) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CardSwiper(
              controller: _swiperController,
              cardsCount: jobs.length,
              // Adaptação dinâmica para evitar o AssertionError
              numberOfCardsDisplayed: jobs.length > 1 ? 2 : 1,
              onEnd: () {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId != null) {
                  _feedController.loadJobs(userId);
                }
              },
              onSwipe: (previousIndex, currentIndex, direction) {
                final job = jobs[previousIndex];
                final userId = Supabase.instance.client.auth.currentUser?.id;

                if (userId == null) return false;

                if (direction == CardSwiperDirection.right) {
                  _feedController.registerAction(
                    candidateId: userId,
                    jobId: job.id,
                    status: InteractionStatus.like,
                  );
                } else if (direction == CardSwiperDirection.left) {
                  _feedController.registerAction(
                    candidateId: userId,
                    jobId: job.id,
                    status: InteractionStatus.dislike,
                  );
                }

                return true;
              },
              allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                horizontal: true,
                vertical: false,
              ),
              cardBuilder: (context, index, x, y) {
                return _buildJobCard(jobs[index]);
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close_rounded,
                color: Colors.redAccent,
                onTap: () => _swiperController.swipe(CardSwiperDirection.left),
              ),
              _buildActionButton(
                icon: Icons.favorite_rounded,
                color: Colors.green,
                onTap: () => _swiperController.swipe(CardSwiperDirection.right),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "Arraste o card ou use os botões.",
              style: AppTextStyles.tutorialArraste,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          job.companyAvatarUrl != null &&
                              job.companyAvatarUrl!.isNotEmpty
                          ? Image.network(
                              job.companyAvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.business,
                                    color: AppColors.secondary,
                                  ),
                            )
                          : Center(
                              child: Text(
                                job.companyName != null &&
                                        job.companyName!.isNotEmpty
                                    ? job.companyName![0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 5. Interpolação segura de Null Safety para o modelo e localização
                        Text(
                          job.location != null
                              ? '${job.workModel.name} • ${job.location}'
                              : job.workModel.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.salary,
                  style: GoogleFonts.montserrat(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.tags.map((tag) => _buildTag(tag)).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Descrição da vaga',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  job.description,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Modular.to.pushNamed(
                    '/candidate/job-details',
                    arguments: job,
                  ),
                  child: Text(
                    'Ver Detalhes',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTitle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 35),
      ),
    );
  }

  // Widget para quando a lista de vagas acabar
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Você chegou ao fim!',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há novas vagas disponíveis no momento. Volte mais tarde!',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para tratar falha de conexão com o banco
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Ops, algo deu errado.',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId != null) _feedController.loadJobs(userId);
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
