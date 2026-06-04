import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/style/app_fonts.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';

class TalentFeedPage extends StatefulWidget {
  const TalentFeedPage({super.key});

  @override
  State<TalentFeedPage> createState() => _TalentFeedPageState();
}

class _TalentFeedPageState extends State<TalentFeedPage> {
  final CardSwiperController _swiperController = CardSwiperController();

  final List<CandidateModel> _mockCandidates = const [
    CandidateModel(
      id: '1',
      name: 'Lucas Richter',
      bio:
          'Desenvolvedor Flutter com foco em interfaces de alta performance, arquitetura limpa e integração com APIs REST.',
      skills: ['Flutter', 'Dart', 'Firebase', 'Clean Architecture'],
    ),
    CandidateModel(
      id: '2',
      name: 'Mariana Silva',
      bio:
          'Engenheira de software com experiência em produtos digitais, liderança técnica e evolução de aplicativos mobile.',
      skills: ['Swift', 'iOS', 'CI/CD', 'Product Design'],
    ),
    CandidateModel(
      id: '3',
      name: 'Carlos Oliveira',
      bio:
          'Desenvolvedor mobile júnior em crescimento acelerado, com boa base em Git, consumo de APIs e trabalho em equipe.',
      skills: ['Flutter', 'Git', 'API REST', 'Scrum'],
    ),
    CandidateModel(
      id: '4',
      name: 'Ana Souza',
      bio:
          'Profissional de mobile com perfil analítico, experiência em interface nativa e interesse em produtos centrados no usuário.',
      skills: ['UIKit', 'SwiftUI', 'Figma', 'UX'],
    ),
  ];

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: const CustomAppBar2(
        title: 'Talentos',
        showProfileAvatar: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CardSwiper(
                  controller: _swiperController,
                  cardsCount: _mockCandidates.length,
                  onEnd: () {
                    // Aqui você pode carregar mais candidatos do backend.
                  },
                  onSwipe: (previousIndex, currentIndex, direction) {
                    if (direction == CardSwiperDirection.right) {
                      debugPrint(
                        'Demonstrou interesse em ${_mockCandidates[previousIndex].name}!',
                      );
                    } else if (direction == CardSwiperDirection.left) {
                      debugPrint(
                        'Descartou ${_mockCandidates[previousIndex].name}!',
                      );
                    }
                    return true;
                  },
                  allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                    horizontal: true,
                    vertical: false,
                  ),
                  cardBuilder: (
                    context,
                    index,
                    horizontalThresholdPercentage,
                    verticalThresholdPercentage,
                  ) {
                    final candidate = _mockCandidates[index];
                    return _buildCandidateCard(candidate);
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
                    onTap: () {
                      _swiperController.swipe(CardSwiperDirection.left);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.favorite_rounded,
                    color: Colors.green,
                    onTap: () {
                      _swiperController.swipe(CardSwiperDirection.right);
                    },
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
        ),
      ),
    );
  }

  Widget _buildCandidateCard(CandidateModel candidate) {
    final skills = candidate.skills;

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
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                    backgroundImage:
                        candidate.avatarUrl != null && candidate.avatarUrl!.isNotEmpty
                            ? NetworkImage(candidate.avatarUrl!)
                            : null,
                    child: candidate.avatarUrl == null || candidate.avatarUrl!.isEmpty
                        ? Text(
                            _initials(candidate.name),
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
                          candidate.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skills.isNotEmpty ? skills.first : 'Talento disponível',
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
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Perfil para análise do time',
                  style: GoogleFonts.montserrat(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) => _buildTag(skill)).toList(),
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
                  candidate.bio ?? 'Sem descrição disponível para este candidato.',
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
                  onPressed: () => Modular.to.pushNamed(
                    './candidate-details',
                    arguments: candidate,
                  ),
                  child: Text(
                    'Ver Perfil',
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'TR';
    if (parts.length == 1) {
      final single = parts.first;
      return single.length >= 2 ? single.substring(0, 2).toUpperCase() : single.toUpperCase();
    }

    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    final initials = '$first$last'.trim();
    return initials.isEmpty ? 'TR' : initials.toUpperCase();
  }
}