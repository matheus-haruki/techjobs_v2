import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/empresa/view/widgets/company_profile_page.dart';
import 'package:techjobs/modules/empresa/view/widgets/my_jobs_page.dart';
import 'package:techjobs/modules/empresa/view/widgets/notifications_page.dart';
import 'package:techjobs/modules/empresa/view/widgets/talent_feed_page.dart';

class CompanyBasePage extends StatefulWidget {
  const CompanyBasePage({super.key});

  @override
  State<CompanyBasePage> createState() => _CompanyBasePageState();
}

class _CompanyBasePageState extends State<CompanyBasePage> {
  int _currentIndex = 0;

  // 1. Declaramos a lista de páginas de forma estática
  final List<Widget> _pages = const [
    TalentFeedPage(),
    MyJobsPage(),
    NotificationsPage(),
    CompanyProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. Substituímos o PageView pelo IndexedStack (sem scroll horizontal)
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.secondaryDark,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Talentos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center_outlined),
              activeIcon: Icon(Icons.business_center_rounded),
              label: 'Vagas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              activeIcon: Icon(Icons.notifications),
              label: 'Notificações',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
