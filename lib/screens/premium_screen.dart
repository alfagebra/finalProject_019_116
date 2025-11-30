import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'payment_offer_screen.dart';
import 'kuis_screen.dart';
import 'profile_screen.dart';
import '../services/notification_service.dart';
import '../database/hive_database.dart';

class PremiumScreen extends StatefulWidget {
  final String username;
  const PremiumScreen({super.key, this.username = "User"});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedIndex = 0;
  late final List<Widget?> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.init(context: context);
    });
    // Lazily create KuisScreen only when the tab is selected to avoid
    // showing modal dialogs / prompts while Home is active (IndexedStack
    // builds all children eagerly). Use null placeholder for lazy pages.
    _pages = [
      HomeTab(username: widget.username, unlockPremium: true),
      const PaymentOfferScreen(),
      null, // will create KuisScreen on demand
      const ProfileScreen(),
    ];
    // PremiumScreen delegates materi loading to HomeTab; no local load.
    // Try to restore last selected tab for this user (per-account)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final hive = HiveDatabase();
        final current = await hive.getCurrentUserEmail();
        if (current != null) {
          final box = await hive.getUserBox();
          final user = box.get(current);
          if (user is Map && user['last_tab'] != null) {
            final val = int.tryParse(user['last_tab'].toString());
            if (val != null && mounted) {
              setState(() {
                _selectedIndex = val.clamp(0, _pages.length - 1);
              });
            }
          }
        }
      } catch (_) {}
    });
  }

  void _onItemTapped(int index) async {
    if (index >= 0 && index < _pages.length) {
      // Recreate KuisScreen each time the tab is selected so any
      // transient dialogs (like the question-count prompt) reappear
      // if the user dismissed them previously.
      if (index == 2) {
        debugPrint('▶️ PremiumScreen: creating KuisScreen for selection');
        _pages[2] = const KuisScreen();
      }
      setState(() => _selectedIndex = index);

      // persist per-user last tab
      try {
        final hive = HiveDatabase();
        final current = await hive.getCurrentUserEmail();
        if (current != null) {
          await hive.updateUser(current, {'last_tab': index});
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _selectedIndex.clamp(0, _pages.length - 1);
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      body: SafeArea(
        child: IndexedStack(
          index: safeIndex,
          children: _pages.map((w) => w ?? const SizedBox()).toList(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Note: Home UI is now reused from `HomeTab`.

  // PremiumScreen reuses HomeTab for the home UI and material list.

  // --- NAVBAR ---
  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: const Color(0xFF012D5A),
      selectedItemColor: Colors.orangeAccent,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment_outlined),
          label: "Pembayaran",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined), label: "Kuis"),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profil",
        ),
      ],
    );
  }
}
