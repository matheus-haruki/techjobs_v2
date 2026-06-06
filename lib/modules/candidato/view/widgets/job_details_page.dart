import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/model/interaction_model.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:techjobs/modules/candidato/usecase/register_interaction_usecase.dart';

class JobDetailsPage extends StatefulWidget {
  final JobModel job;

  const JobDetailsPage({super.key, required this.job});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late bool _isSubscribed;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa o estado com a flag que veio do banco de dados no JobModel
    _isSubscribed = widget.job.isSubscribed;
  }

  Future<void> _handleSubscription() async {
    if (_isSubscribed || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado.');

      // 1. Criamos a instância do modelo conforme o contrato do seu UseCase
      final interaction = InteractionModel(
        id:'',
        candidateId: userId,
        jobId: widget.job.id,
        status: InteractionStatus.like,
        createdAt: DateTime.now(),
      );

      // 2. Chamamos o UseCase passando o objeto posicional
      final registerUseCase = Modular.get<IRegisterInteractionUseCase>();
      await registerUseCase.call(interaction);

      if (mounted) {
        setState(() {
          _isSubscribed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrição realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: const CustomAppBar(
        title: 'Detalhes da Vaga',
        showProfileAvatar: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Cabeçalho da Vaga (Clicável para ir à Empresa)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (widget.job.companyId != null) {
                    Modular.to.pushNamed(
                      './company-details',
                      arguments: widget.job.companyId,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryDark.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: widget.job.companyAvatarUrl != null &&
                                  widget.job.companyAvatarUrl!.isNotEmpty
                              ? Image.network(
                                  widget.job.companyAvatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.business,
                                    color: AppColors.secondary,
                                    size: 36,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    widget.job.companyName != null &&
                                            widget.job.companyName!.isNotEmpty
                                        ? widget.job.companyName![0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 28,
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
                              widget.job.title,
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textTitle,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.job.companyName ?? 'Empresa Confidencial',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      Icons.location_on_outlined,
                      widget.job.location ?? 'Remoto',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(Icons.payments_outlined, widget.job.salary),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Tecnologias',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.job.tags.map((tag) => _buildTag(tag)).toList(),
              ),
              const SizedBox(height: 32),
              Text(
                'Sobre a vaga',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  widget.job.description,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // BOTÃO FIXO DE INSCRIÇÃO NO RODAPÉ
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          24, 
          16, 
          24, 
          MediaQuery.of(context).padding.bottom + 16, // SafeArea para o botão
        ),
        child: ElevatedButton(
          onPressed: _isSubscribed ? null : _handleSubscription,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSubscribed ? Colors.green.shade50 : AppColors.primary,
            elevation: _isSubscribed ? 0 : 2,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: _isSubscribed 
                ? BorderSide(color: Colors.green.shade200) 
                : BorderSide.none,
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSubscribed ? Icons.check_circle_rounded : Icons.favorite_border_rounded,
                      color: _isSubscribed ? Colors.green.shade700 : Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isSubscribed ? 'Você já está inscrito!' : 'Dar Like na Vaga',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isSubscribed ? Colors.green.shade700 : Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 28),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}