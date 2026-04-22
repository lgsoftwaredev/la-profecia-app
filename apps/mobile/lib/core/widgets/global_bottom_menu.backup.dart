import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xCC2B3568), Color(0xB2212854)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  for (final menuItem in _items)
                    Expanded(
                      flex: currentItem == menuItem.item ? 2 : 1,
                      child: _BottomMenuButton(
                        iconAsset: menuItem.iconAsset,
                        label: menuItem.label,
                        isSelected: currentItem == menuItem.item,
                        onTap: () => onItemSelected?.call(menuItem.item),
                      ),
                    ),
                ],
              ),
            ),
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

class _BottomMenuButton extends StatelessWidget {
  const _BottomMenuButton({
    required this.iconAsset,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? AppSpacing.md : AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: isSelected
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MenuIcon(assetPath: iconAsset, size: 32),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                        ),
                      ),
                    ],
                  )
                : _MenuIcon(assetPath: iconAsset, size: 28, opacity: 0.92),
          ),
        ),
      ),
    );
  }
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
