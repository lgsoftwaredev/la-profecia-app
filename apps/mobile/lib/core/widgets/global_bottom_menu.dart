import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';

import '../theme/app_spacing.dart';

enum GlobalBottomMenuItem { home, ranking, profile, settings }

class GlobalBottomMenu extends StatelessWidget {
  const GlobalBottomMenu({
    required this.currentItem,
    this.onItemSelected,
    super.key,
  });

  final GlobalBottomMenuItem currentItem;
  final ValueChanged<GlobalBottomMenuItem>? onItemSelected;

  static const _items = <_BottomMenuItemData>[
    _BottomMenuItemData(
      item: GlobalBottomMenuItem.home,
      label: 'Home',
      iconAsset: 'assets/menu-logo-icon-home.png',
    ),
    _BottomMenuItemData(
      item: GlobalBottomMenuItem.ranking,
      label: 'Premium',
      iconAsset: 'assets/menu-logo-icon-premium.png',
    ),
    _BottomMenuItemData(
      item: GlobalBottomMenuItem.profile,
      label: 'Perfil',
      iconAsset: 'assets/menu-logo-icon-profile.png',
    ),
    _BottomMenuItemData(
      item: GlobalBottomMenuItem.settings,
      label: 'Ajustes',
      iconAsset: 'assets/menu-logo-icon-settings.png',
    ),
  ];

  int _indexForItem(GlobalBottomMenuItem item) {
    final index = _items.indexWhere((menuItem) => menuItem.item == item);
    return index < 0 ? 0 : index;
  }

  GlobalBottomMenuItem _itemForIndex(int index) {
    if (index < 0 || index >= _items.length) {
      return GlobalBottomMenuItem.home;
    }
    return _items[index].item;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: LGBottomBar(
          tabs: [
            for (final menuItem in _items)
              LGBottomBarTab(
                label: menuItem.label,
                iconWidget: _MenuIcon(
                  assetPath: menuItem.iconAsset,
                  size: 25,
                  opacity: 0.92,
                ),
                selectedIconWidget: _SelectedMenuIcon(
                  assetPath: menuItem.iconAsset,
                ),
                selectedLabelColor: Colors.white,
                unselectedLabelColor: Colors.transparent,
              ),
          ],
          selectedIndex: _indexForItem(currentItem),
          onTabSelected: (index) => onItemSelected?.call(_itemForIndex(index)),
          showLabel: true,
          quality: LGQuality.standard,
          barHeight: 70,
          barBorderRadius: 999,
          horizontalPadding: 0,
          verticalPadding: 0,
          tabPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          spacing: 10,
          blendAmount: 1,
          indicatorColor: Colors.white.withValues(alpha: 0.22),
          indicatorSettings: const LiquidGlassSettings(
            blur: 2,
            thickness: 16,
            glassColor: Color(0x29FFFFFF),
            refractiveIndex: 1.15,
          ),
          glassSettings: const LiquidGlassSettings(
            thickness: 10,
            blur: 2,
            chromaticAberration: 0.3,
            lightIntensity: 0.8,
            refractiveIndex: 1.25,
            saturation: 1.05,
            glassColor: Color.fromARGB(29, 255, 255, 255),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _BottomMenuItemData {
  const _BottomMenuItemData({
    required this.item,
    required this.label,
    required this.iconAsset,
  });

  final GlobalBottomMenuItem item;
  final String label;
  final String iconAsset;
}

class _MenuIcon extends StatelessWidget {
  const _MenuIcon({
    required this.assetPath,
    required this.size,
    this.opacity = 1,
  });

  final String assetPath;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      opacity: opacity,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _SelectedMenuIcon extends StatelessWidget {
  const _SelectedMenuIcon({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return _MenuIcon(assetPath: assetPath, size: 32);
  }
}
