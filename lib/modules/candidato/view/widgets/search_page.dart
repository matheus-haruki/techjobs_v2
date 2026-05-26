import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/components/custom_app_bar.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/model/job_model.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // Para controlar qual tag de filtro está ativa

  // Lista de filtros rápidos
  final List<String> _filters = [
    'Todas',
    'Remoto',
    'Júnior',
    'Pleno',
    'Sênior',
    'Exterior',
  ];

  // Aproveitando os mesmos dados (Mock) para não termos que recriar
  final List<JobModel> _mockJobs = [
    JobModel(
      id: '1',
      title: 'Desenvolvedor(a) Flutter Pleno',
      company: 'TechCorp S/A',
      location: 'Remoto',
      salary: 'R\$ 6.000 - R\$ 8.000',
      tags: ['Flutter', 'Dart', 'Firebase'],
      description: 'Buscamos uma pessoa desenvolvedora...',
    ),
    JobModel(
      id: '2',
      title: 'Engenheiro iOS Senior',
      company: 'AppleBR',
      location: 'São Paulo, SP',
      salary: 'R\$ 12.000 - R\$ 16.000',
      tags: ['Swift', 'Objective-C', 'Viper'],
      description: 'Venha liderar tecnicamente...',
    ),
    JobModel(
      id: '3',
      title: 'Dev Mobile Júnior (Flutter)',
      company: 'StartupX',
      location: 'Híbrido - Curitiba',
      salary: 'R\$ 3.500 - R\$ 4.500',
      tags: ['Flutter', 'Git', 'API Rest'],
      description: 'Ótima oportunidade para quem quer crescer...',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: const CustomAppBar(title: 'Buscar Vagas'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. Barra de Pesquisa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Ex: Desenvolvedor Flutter...',
                  hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.secondary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Filtros Rápidos (Scroll Horizontal)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: GoogleFonts.montserrat(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 3. Lista de Resultados
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _mockJobs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final job = _mockJobs[index];
                  return _buildCompactJobCard(job);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente para desenhar o Card Compacto na lista
  // Componente para desenhar o Card Compacto na lista
  Widget _buildCompactJobCard(JobModel job) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Modular.to.pushNamed(
            './job-details',
            arguments: job,
          ), // Ação de clique chamando a rota
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo da Empresa
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.business, color: AppColors.secondary),
                ),
                const SizedBox(width: 16),

                // Detalhes da Vaga
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textTitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.location,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Ícone de "Ver detalhes"
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.chevron_right, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
