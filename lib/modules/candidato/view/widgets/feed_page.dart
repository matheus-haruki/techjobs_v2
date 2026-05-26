import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart'; // <-- Pacote importado!
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/core/style/app_fonts.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // O controlador que vai permitir que os botões arrastem o card automaticamente
  final CardSwiperController _swiperController = CardSwiperController();

  final List<JobModel> _mockJobs = [
    JobModel(
      id: '1',
      title: 'Desenvolvedor(a) Flutter Pleno',
      company: 'TechCorp S/A',
      location: 'Remoto',
      salary: 'R\$ 6.000 - R\$ 8.000',
      tags: ['Flutter', 'Dart', 'Firebase', 'Clean Arch'],
      description:
          'Buscamos uma pessoa desenvolvedora Flutter para atuar na construção de interfaces modernas, integração com APIs e evolução contínua de um aplicativo em crescimento. A equipe trabalha com boa autonomia e foco em qualidade.',
    ),
    JobModel(
      id: '2',
      title: 'Engenheiro iOS Senior',
      company: 'AppleBR',
      location: 'São Paulo, SP',
      salary: 'R\$ 12.000 - R\$ 16.000',
      tags: ['Swift', 'Objective-C', 'Viper', 'XCode'],
      description:
          'Venha liderar tecnicamente a nossa guilda de iOS. O candidato ideal tem sólida experiência com Swift nativo, modularização de apps em grande escala e publicação automatizada via CI/CD.',
    ),
    JobModel(
      id: '3',
      title: 'Dev Mobile Júnior (Flutter)',
      company: 'StartupX',
      location: 'Híbrido - Curitiba',
      salary: 'R\$ 3.500 - R\$ 4.500',
      tags: ['Flutter', 'Git', 'API Rest', 'Scrum'],
      description:
          'Ótima oportunidade para quem quer crescer! Você vai atuar lado a lado com desenvolvedores sêniores ajudando a migrar nosso app legado para Flutter. Necessário conhecimento básico de gerência de estado.',
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
      backgroundColor: AppColors.primary,
      appBar: const CustomAppBar(title: 'Feed de Vagas'),
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
              // Nossa pilha mágica de Cards!
              Expanded(
                child: CardSwiper(
                  controller: _swiperController,
                  cardsCount: _mockJobs.length,
                  // O que acontece quando os cards acabam:
                  onEnd: () {
                    // Aqui você poderia carregar mais vagas do backend
                  },
                  // Controla o que acontece no momento do swipe
                  onSwipe: (previousIndex, currentIndex, direction) {
                    if (direction == CardSwiperDirection.right) {
                      debugPrint(
                        'Deu Like na vaga ${_mockJobs[previousIndex].title}!',
                      );
                    } else if (direction == CardSwiperDirection.left) {
                      debugPrint(
                        'Recusou a vaga ${_mockJobs[previousIndex].title}!',
                      );
                    }
                    return true; // Retorna true para permitir a animação
                  },
                  // Evita que arraste para cima/baixo se você não quiser
                  allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                    horizontal: true,
                    vertical: false,
                  ),
                  // Constrói o card visualmente
                  cardBuilder:
                      (
                        context,
                        index,
                        horizontalThresholdPercentage,
                        verticalThresholdPercentage,
                      ) {
                        final job = _mockJobs[index];
                        return _buildJobCard(job);
                      },
                ),
              ),

              const SizedBox(height: 20),

              // Botões de Like e Dislike
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.close_rounded,
                    color: Colors.redAccent,
                    onTap: () {
                      // Simula um swipe para a esquerda
                      _swiperController.swipe(CardSwiperDirection.left);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.favorite_rounded,
                    color: Colors.green,
                    onTap: () {
                      // Simula um swipe para a direita
                      _swiperController.swipe(CardSwiperDirection.right);
                    },
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
        ),
      ),
    );
  }

  // Isolei o visual do Card que você desenhou aqui para o build ficar mais limpo
  Widget _buildJobCard(JobModel job) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        // Diminuí um pouco o padding geral de 24 para 20 para dar mais respiro
        padding: const EdgeInsets.all(20.0),
        // 👇 A MÁGICA AQUI: O scroll interno evita qualquer quebra de tela!
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(), // Dá aquele efeito de elástico suave
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
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
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
                            fontSize:
                                18, // Diminuí levemente a fonte do título para telas menores
                            fontWeight: FontWeight.bold,
                            color: AppColors.textTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${job.company} • ${job.location}',
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
              const SizedBox(
                height: 20,
              ), // Diminuí os espaçamentos de 24 para 20

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:0.1),
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
                  // Retornamos a restrição de 3 linhas com reticências!
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
        ), // Fecha o SingleChildScrollView
      ), // Fecha o Padding
    ); // Fecha o Container principal do card
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
              color: color.withValues(alpha:0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 35),
      ),
    );
  }
}
