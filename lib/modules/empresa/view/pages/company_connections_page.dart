// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:techjobs/core/components/custom_app_bar.dart';
// import 'package:techjobs/core/style/app_colors.dart';
// import 'package:techjobs/modules/empresa/model/company_connection_model.dart';

// class CompanyConnectionsPage extends StatelessWidget {
//   const CompanyConnectionsPage({super.key});

//   // Mock injetado diretamente para o desenvolvimento da UI.
//   // Posteriormente, isso virá de um Controller (ex: CompanyConnectionsController).
//   static const List<CompanyConnectionModel> _mockConnections = [
//     CompanyConnectionModel(
//       candidateId: '1',
//       candidateName: 'Lucas Richter',
//       role: 'Desenvolvedor Flutter Pleno',
//       matchedJobTitle: 'Desenvolvedor(a) Flutter Pleno',
//       matchDate: 'Hoje',
//       hasUnreadMessages: true,
//     ),
//     CompanyConnectionModel(
//       candidateId: '2',
//       candidateName: 'Beatriz Soares',
//       role: 'Dev Mobile iOS Senior',
//       matchedJobTitle: 'Tech Lead Mobile',
//       matchDate: 'Ontem',
//       hasUnreadMessages: false,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.secondary,
//       appBar: const CustomAppBar2(title: 'Conexões', showProfileAvatar: false),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: _mockConnections.isEmpty
//             ? _buildEmptyState()
//             : ListView.separated(
//                 padding: const EdgeInsets.all(24.0),
//                 itemCount: _mockConnections.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 16),
//                 itemBuilder: (context, index) {
//                   return _buildConnectionCard(context, _mockConnections[index]);
//                 },
//               ),
//       ),
//     );
//   }

//   Widget _buildConnectionCard(
//     BuildContext context,
//     CompanyConnectionModel connection,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Stack(
//             children: [
//               CircleAvatar(
//                 radius: 28,
//                 backgroundColor: AppColors.secondary.withOpacity(0.2),
//                 child: Text(
//                   connection.candidateName.substring(0, 2).toUpperCase(),
//                   style: GoogleFonts.montserrat(
//                     color: AppColors.secondary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               if (connection.hasUnreadMessages)
//                 Positioned(
//                   right: 0,
//                   top: 0,
//                   child: Container(
//                     width: 14,
//                     height: 14,
//                     decoration: BoxDecoration(
//                       color: Colors.redAccent,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   connection.candidateName,
//                   style: GoogleFonts.montserrat(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textTitle,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   connection.role,
//                   style: GoogleFonts.montserrat(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     'Vaga: ${connection.matchedJobTitle}',
//                     style: GoogleFonts.montserrat(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.primary,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 connection.matchDate,
//                 style: GoogleFonts.montserrat(
//                   fontSize: 12,
//                   color: Colors.grey.shade400,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.people_alt_outlined,
//             size: 80,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Sem conexões ainda',
//             style: GoogleFonts.montserrat(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Continue avaliando candidatos no feed.',
//             style: GoogleFonts.montserrat(
//               fontSize: 14,
//               color: Colors.grey.shade500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
