import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../widgets/tutorial_first_view.dart';
import '../widgets/tutorial_fourth_view.dart';
import '../widgets/tutorial_page_indicator.dart';
import '../widgets/tutorial_second_view.dart';
import '../widgets/tutorial_third_view.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  static const _totalPages = 4;

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_currentIndex >= _totalPages - 1) {
      if (!mounted) {
        return;
      }
      await AppScope.I.analyticsService.logTutorialCompleted();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
      );
      return;
    }

    await _pageController.animateToPage(
      _currentIndex + 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: const [
                TutorialFirstView(),
                TutorialSecondView(),
                TutorialThirdView(),
                TutorialFourthView(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    26,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TutorialPageIndicator(
                        currentIndex: _currentIndex,
                        totalPages: _totalPages,
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.lg,
                            right: AppSpacing.lg,
                          ),
                          child: App3dPillButton(
                            onTap: _goNext,
                            label: _currentIndex == _totalPages - 1
                                ? 'Vamos a jugar'
                                : 'Siguiente',
                            color: _currentIndex == _totalPages - 1
                                ? AppColors.primary
                                : AppColors.surface,
                            height: 56,
                            depth: 3.5,
                            textStyle: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: _currentIndex == _totalPages - 1
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
