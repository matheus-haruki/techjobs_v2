import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techjobs/core/style/app_colors.dart';

class CompanyBasePage extends StatefulWidget {
  const CompanyBasePage({super.key});

  @override
  State<CompanyBasePage> createState() => _CompanyBasePageState();
}

class _CompanyBasePageState extends State<CompanyBasePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Aguarda o primeiro frame da UI ser desenhado para que o RouterOutlet esteja pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Injeta a rota de Talentos automaticamente no inicialização
      Modular.to.navigate('/company/talents');
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    // Delegação do roteamento para o Modular
    switch (index) {
      case 0:
        Modular.to.navigate('/company/talents');
        break;
      case 1:
        Modular.to.navigate('/company/jobs');
        break;
      case 2:
        Modular.to.navigate('/company/notifications');
        break;
      case 3:
        Modular.to.navigate('/company/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O IndexedStack foi removido. O RouterOutlet assume o controle do sub-roteamento.
      body: const RouterOutlet(),
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
