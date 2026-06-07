import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/style/app_fonts.dart';
import 'package:techjobs/modules/empresa/controller/talent_feed_controller.dart';
import 'package:techjobs/modules/empresa/model/job_model.dart';
import 'package:techjobs/modules/empresa/model/talent_model.dart';
import 'package:techjobs/modules/empresa/model/interaction_model.dart'; // Importação adicionada

class TalentFeedPage extends StatefulWidget {
  const TalentFeedPage({super.key});

  @override
  State<TalentFeedPage> createState() => _TalentFeedPageState();
}

class _TalentFeedPageState extends State<TalentFeedPage> {
  final _controller = Modular.get<TalentFeedController>();
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadFeedData();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: const CustomAppBar2(title: 'Talentos', showProfileAvatar: false),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildJobSelectorBox(),
            Expanded(child: _buildFeedState()),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSelectorBox() {
    return ValueListenableBuilder<List<JobModel>>(
      valueListenable: _controller.activeJobs,
      builder: (context, activeJobs, child) {
        if (activeJobs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.orange.shade50,
            child: Text(
              'Crie e ative uma vaga para buscar talentos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BUSCANDO TALENTOS PARA:',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<JobModel?>(
                valueListenable: _controller.selectedJob,
                builder: (context, selectedJob, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<JobModel>(
                        value: selectedJob,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.secondary,
                        ),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTitle,
                        ),
                        items: activeJobs.map((job) {
                          return DropdownMenuItem<JobModel>(
                            value: job,
                            child: Text(job.title),
                          );
                        }).toList(),
                        onChanged: (JobModel? newJob) {
                          if (newJob != null) {
                            _controller.selectJob(newJob);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedState() {
    return ValueListenableBuilder<AppState<List<TalentModel>>>(
      valueListenable: _controller.talentsState,
      builder: (context, state, child) {
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }

        if (state is ErrorState<List<TalentModel>>) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Erro ao carregar talentos:\n${state.message}',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: Colors.red),
              ),
            ),
          );
        }

        if (state is SuccessState<List<TalentModel>>) {
          final talents = state.data;

          if (talents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum talento encontrado',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }

          return _buildSwiperArea(talents);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSwiperArea(List<TalentModel> talents) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: _swiperController,
              cardsCount: talents.length,
              numberOfCardsDisplayed: talents.length == 1 ? 1 : 2,
              isLoop: false,
              // Sincroniza o fim da pilha visual com o estado lógico
              onEnd: () {
                _controller.markFeedAsEmpty();
              },
              allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                horizontal: true,
                vertical: false,
              ),
              onSwipe: (previousIndex, currentIndex, direction) {
                final talent = talents[previousIndex];
                final activeJob = _controller.selectedJob.value;

                if (activeJob == null) return false;

                if (direction == CardSwiperDirection.right) {
                  _controller.registerSwipe(
                    talent: talent,
                    status: InteractionStatus.like,
                  );
                } else if (direction == CardSwiperDirection.left) {
                  _controller.registerSwipe(
                    talent: talent,
                    status: InteractionStatus.dislike,
                  );
                }
                return true;
              },
              cardBuilder: (context, index, x, y) {
                return _buildCandidateCard(talents[index]);
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
              'Arraste o card ou use os botões.',
              style: AppTextStyles.tutorialArraste,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(TalentModel talent) {
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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.secondary.withValues(
                      alpha: 0.15,
                    ),
                    backgroundImage:
                        talent.avatarUrl != null && talent.avatarUrl!.isNotEmpty
                        ? NetworkImage(talent.avatarUrl!)
                        : null,
                    child: talent.avatarUrl == null || talent.avatarUrl!.isEmpty
                        ? Text(
                            _initials(talent.name),
                            style: GoogleFonts.montserrat(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          talent.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          talent.role ??
                              (talent.skills.isNotEmpty
                                  ? talent.skills.first
                                  : 'Talento disponível'),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: talent.skills
                    .map((skill) => _buildTag(skill))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Resumo',
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
                  talent.bio ?? 'Sem descrição disponível para este candidato.',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    final currentJob = _controller.selectedJob.value;
                    if (currentJob != null) {
                      Modular.to.pushNamed(
                        './candidate-details',
                        arguments: {
                          'candidateId': talent.id,
                          'jobId': currentJob.id,
                          'isReadOnly': true, // Bloqueia o botão "Dar Match"
                        },
                      );
                    }
                  },
                  child: Text(
                    'Ver Perfil',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
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
    return ValueListenableBuilder<JobModel?>(
      valueListenable: _controller.selectedJob,
      builder: (context, selectedJob, child) {
        final isEnabled = selectedJob != null;
        final buttonColor = isEnabled ? color : Colors.grey.shade300;

        return GestureDetector(
          onTap: isEnabled ? onTap : null,
          child: Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                if (isEnabled)
                  BoxShadow(
                    color: buttonColor.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Icon(icon, color: buttonColor, size: 35),
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'TR';
    if (parts.length == 1) {
      final single = parts.first;
      return single.length >= 2
          ? single.substring(0, 2).toUpperCase()
          : single.toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}
