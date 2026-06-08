import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/empresa/controller/my_jobs_controller.dart';
import 'package:techjobs/modules/empresa/model/job_model.dart';

class CreateJobPage extends StatefulWidget {
  const CreateJobPage({super.key});

  @override
  State<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _controller = Modular.get<MyJobsController>();

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _salaryMinController; // Novo Controlador Mínimo
  late TextEditingController _salaryMaxController; // Novo Controlador Máximo
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;

  WorkModel _selectedWorkModel = WorkModel.presencial;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
    _salaryMinController = TextEditingController();
    _salaryMaxController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: const CustomAppBar2(title: 'Nova Vaga', showProfileAvatar: false),
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
              Text(
                'INFORMAÇÕES PRINCIPAIS',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Título da Vaga',
                hint: 'Ex: Desenvolvedor(a) Flutter Pleno',
                controller: _titleController,
              ),
              const SizedBox(height: 16),

              _buildWorkModelDropdown(),
              const SizedBox(height: 16),

              // Localização agora ocupa a linha toda
              _buildInputField(
                label: 'Localização',
                hint: 'Ex: São Paulo, SP ou Remoto',
                controller: _locationController,
              ),
              const SizedBox(height: 16),

              // Salários lado a lado limitados a números
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'Salário Mínimo',
                      hint: 'Ex: 5000',
                      controller: _salaryMinController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      label: 'Salário Máximo',
                      hint: 'Ex: 6000',
                      controller: _salaryMaxController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 24),

              Text(
                'DETALHES DA VAGA',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Habilidades Desejadas (separadas por vírgula)',
                hint: 'Ex: Flutter, Dart, Firebase, Git',
                controller: _tagsController,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Descrição e Requisitos',
                hint:
                    'Descreva as atividades, responsabilidades e os requisitos técnicos para a vaga...',
                controller: _descriptionController,
                maxLines: 5,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ValueListenableBuilder<AppState<List<JobModel>>>(
            valueListenable: _controller,
            builder: (context, state, child) {
              final isLoading = state is LoadingState<List<JobModel>>;

              return ElevatedButton(
                onPressed: isLoading ? null : _saveJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Publicar Vaga',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveJob() async {
    final companyId = Supabase.instance.client.auth.currentUser?.id;
    if (companyId == null) return;

    final rawTags = _tagsController.text;
    final tagsList = rawTags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    // Lógica Inteligente para o Range de Salário
    String minSal = _salaryMinController.text.trim();
    String maxSal = _salaryMaxController.text.trim();
    String formattedSalary = '';

    if (minSal.isNotEmpty && maxSal.isNotEmpty) {
      formattedSalary = 'R\$ $minSal - R\$ $maxSal';
    } else if (minSal.isNotEmpty) {
      formattedSalary = 'A partir de R\$ $minSal';
    } else if (maxSal.isNotEmpty) {
      formattedSalary = 'Até R\$ $maxSal';
    } else {
      formattedSalary = 'A combinar';
    }

    final job = JobModel(
      id: '',
      companyId: companyId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      workModel: _selectedWorkModel,
      location: _locationController.text.trim(),
      salary: formattedSalary, // Salvando o salário já formatado
      tags: tagsList,
      isActive: true,
    );

    final success = await _controller.createJob(job);

    if (!mounted) return;

    if (success) {
      Modular.to.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vaga publicada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final state = _controller.value;
      if (state is ErrorState<List<JobModel>>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildWorkModelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modelo de Trabalho',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<WorkModel>(
              value: _selectedWorkModel,
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.grey,
              ),
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: AppColors.textTitle,
              ),
              items: const [
                DropdownMenuItem(
                  value: WorkModel.presencial,
                  child: Text('Presencial'),
                ),
                DropdownMenuItem(
                  value: WorkModel.hibrido,
                  child: Text('Híbrido'),
                ),
                DropdownMenuItem(
                  value: WorkModel.remoto,
                  child: Text('Remoto'),
                ),
              ],
              onChanged: (WorkModel? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedWorkModel = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // O InputField agora recebe o keyboardType para exibir o teclado numérico
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType, // Aplica o tipo de teclado
          style: GoogleFonts.montserrat(
            fontSize: 15,
            color: AppColors.textTitle,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
