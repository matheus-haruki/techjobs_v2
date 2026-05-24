import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importante para ler os seus ícones .svg
import 'package:techjobs/core/style/app_colors.dart';
import 'package:techjobs/modules/candidato/view/widgets/connections_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/feed_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/notifications_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/profile_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/search_page.dart';

class BaseCandidatePage extends StatefulWidget {
  const BaseCandidatePage({super.key});

  @override
  State<BaseCandidatePage> createState() => _BaseCandidatePageState();
}

class _BaseCandidatePageState extends State<BaseCandidatePage> {
  int _currentIndex = 0; // Controla qual aba está ativa

  // Lista com as 5 páginas na ordem exata do menu
  final List<Widget> _pages = [
    const FeedPage(),
    const SearchPage(),
    const ConnectionsPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  // Cor padrão do app para itens ativos e inativos
  final Color _activeColor = AppColors.primaryDark;
  final Color _inactiveColor = AppColors.textBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O IndexedStack mantém o estado de todas as telas vivo ao alternar as abas
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType
              .fixed, // Garante que as 5 abas caibam perfeitamente
          backgroundColor: AppColors.white,
          selectedItemColor: _activeColor,
          unselectedItemColor: _inactiveColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                colorFilter: ColorFilter.mode(
                  _currentIndex == 0 ? _activeColor : _inactiveColor,
                  BlendMode.srcIn,
                ),
                height: 20,
              ),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/search.svg', // Corrigi o "serach.svg" do caminho para o padrão correto
                colorFilter: ColorFilter.mode(
                  _currentIndex == 1 ? _activeColor : _inactiveColor,
                  BlendMode.srcIn,
                ),
                height: 20,
              ),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/match.svg',
                colorFilter: ColorFilter.mode(
                  _currentIndex == 2 ? _activeColor : _inactiveColor,
                  BlendMode.srcIn,
                ),
                height: 20,
              ),
              label: 'Conexões',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/notification.svg',
                colorFilter: ColorFilter.mode(
                  _currentIndex == 3 ? _activeColor : _inactiveColor,
                  BlendMode.srcIn,
                ),
                height: 20,
              ),
              label: 'Notificações',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/profile.svg',
                colorFilter: ColorFilter.mode(
                  _currentIndex == 4 ? _activeColor : _inactiveColor,
                  BlendMode.srcIn,
                ),
                height: 20,
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
