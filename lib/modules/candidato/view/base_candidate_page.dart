import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:techjobs/modules/candidato/controller/candidate_controller.dart';
import 'package:techjobs/modules/candidato/view/widgets/connections_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/feed_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/notifications_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/profile_page.dart';
import 'package:techjobs/modules/candidato/view/widgets/search_page.dart'; // <-- Importante

class BaseCandidatePage extends StatefulWidget {
  const BaseCandidatePage({super.key});

  @override
  State<BaseCandidatePage> createState() => _BaseCandidatePageState();
}

class _BaseCandidatePageState extends State<BaseCandidatePage> {
  // Recupera o controller do Modular
  final _controller = Modular.get<CandidateController>();

  final List<Widget> _pages = [
    const FeedPage(),
    const SearchPage(),
    const ConnectionsPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  final Color _activeColor = const Color(0xFF5A92AA);
  final Color _inactiveColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    // Usamos o ValueListenableBuilder para redesenhar a tela quando a aba mudar
    return ValueListenableBuilder<int>(
      valueListenable: _controller,
      builder: (context, currentIndex, child) {
        return Scaffold(
          body: IndexedStack(index: currentIndex, children: _pages),
          bottomNavigationBar: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              currentIndex: currentIndex,
              onTap: _controller.changeTab, // Altera a aba pelo controller
              type: BottomNavigationBarType.fixed,
              selectedItemColor: _activeColor,
              unselectedItemColor: _inactiveColor,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_rounded,
                    color: currentIndex == 0 ? _activeColor : _inactiveColor,
                  ),
                  label: 'Feed',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.search_rounded,
                    color: currentIndex == 1 ? _activeColor : _inactiveColor,
                  ),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.favorite_rounded,
                    color: currentIndex == 2 ? _activeColor : _inactiveColor,
                  ),
                  label: 'Conexões',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications_rounded,
                    color: currentIndex == 3 ? _activeColor : _inactiveColor,
                  ),
                  label: 'Notif.',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_rounded,
                    color: currentIndex == 4 ? _activeColor : _inactiveColor,
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
