import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'home_page.dart';

class MainMenuShellPage extends ConsumerStatefulWidget {
  const MainMenuShellPage({super.key});

  @override
  ConsumerState<MainMenuShellPage> createState() => _MainMenuShellPageState();
}

class _MainMenuShellPageState extends ConsumerState<MainMenuShellPage> {
  var _currentItem = GlobalBottomMenuItem.home;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indexForItem(_currentItem));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onMenuItemSelected(GlobalBottomMenuItem item) async {
    if (item == _currentItem) {
      return;
    }

    if (!mounted) {
      return;
    }

    final targetIndex = _indexForItem(item);
    setState(() {
      _currentItem = item;
    });

    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pageController.hasClients || !mounted) {
        return;
      }
      _pageController.jumpToPage(targetIndex);
    });
  }

  void _onPageRequestsTab(GlobalBottomMenuItem item) {
    unawaited(_onMenuItemSelected(item));
  }

  int _indexForItem(GlobalBottomMenuItem item) {
    switch (item) {
      case GlobalBottomMenuItem.home:
        return 0;
      case GlobalBottomMenuItem.ranking:
        return 1;
      case GlobalBottomMenuItem.profile:
        return 2;
      case GlobalBottomMenuItem.settings:
        return 3;
    }
  }

  GlobalBottomMenuItem _itemForIndex(int index) {
    switch (index) {
      case 0:
        return GlobalBottomMenuItem.home;
      case 1:
        return GlobalBottomMenuItem.ranking;
      case 2:
        return GlobalBottomMenuItem.profile;
      case 3:
      default:
        return GlobalBottomMenuItem.settings;
    }
  }

  void _onPageChanged(int index) {
    final selectedItem = _itemForIndex(index);
    if (selectedItem == _currentItem || !mounted) {
      return;
    }
    setState(() {
      _currentItem = selectedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomePage(
            showBottomMenu: false,
            onGlobalMenuRequested: _onPageRequestsTab,
          ),
          PremiumMenuPage(
            showBottomMenu: false,
            onGlobalMenuRequested: _onPageRequestsTab,
          ),
          ProfilePage(
            showBottomMenu: false,
            isTabActive: _currentItem == GlobalBottomMenuItem.profile,
            onGlobalMenuRequested: _onPageRequestsTab,
          ),
          SettingsPage(
            showBottomMenu: false,
            onGlobalMenuRequested: _onPageRequestsTab,
          ),
        ],
      ),
      bottomNavigationBar: GlobalBottomMenu(
        currentItem: _currentItem,
        onItemSelected: _onMenuItemSelected,
      ),
    );
  }
}
