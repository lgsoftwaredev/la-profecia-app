import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/home_mode_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _currentItem = GlobalBottomMenuItem.home;

  void _onItemSelected(GlobalBottomMenuItem item) {
    if (item == GlobalBottomMenuItem.ranking) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()));
      return;
    }
    if (item == GlobalBottomMenuItem.profile) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage()));
      return;
    }
    if (item == GlobalBottomMenuItem.settings) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
      return;
    }

    setState(() {
      _currentItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background-home.png', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x4D04010B), AppColors.backgroundOverlayBottom],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Image.asset(
                  'assets/logo-+18.png',
                  width: 168,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.xxl * 1.5),
                const Expanded(child: HomeModeCarousel()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlobalBottomMenu(
        currentItem: _currentItem,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
