import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liquid_glass_plus/buttons/liquid_glass_button_group.dart';
import 'package:flutter_liquid_glass_plus/buttons/liquid_glass_chip.dart';
import 'package:flutter_liquid_glass_plus/buttons/liquid_glass_icon_button.dart';
import 'package:flutter_liquid_glass_plus/buttons/liquid_glass_panel.dart';
import 'package:flutter_liquid_glass_plus/buttons/liquid_glass_slider.dart';
import 'package:flutter_liquid_glass_plus/buttons/liquid_glass_switch.dart';
import 'package:flutter_liquid_glass_plus/entry/liquid_glass_form_field.dart';
import 'package:flutter_liquid_glass_plus/entry/liquid_glass_picker.dart';
import 'package:flutter_liquid_glass_plus/entry/liquid_glass_search_bar.dart';
import 'package:flutter_liquid_glass_plus/entry/liquid_glass_text_area.dart';
import 'package:flutter_liquid_glass_plus/entry/liquid_password_field.dart';
import 'package:flutter_liquid_glass_plus/flutter_liquid_glass.dart';
import 'package:flutter_liquid_glass_plus/overlays/liquid_glass_dialog.dart';
import 'package:flutter_liquid_glass_plus/overlays/liquid_glass_menu.dart';
import 'package:flutter_liquid_glass_plus/overlays/liquid_glass_menu_item.dart';
import 'package:flutter_liquid_glass_plus/shared/liquid_glass_indicator.dart';
import 'package:flutter_liquid_glass_plus/surfaces/liquid_glass_side_bar.dart';
import 'package:flutter_liquid_glass_plus/surfaces/liquid_glass_tab_bar.dart';

import '../../../../core/theme/app_spacing.dart';

class LiquidGlassDemoPage extends StatefulWidget {
  const LiquidGlassDemoPage({super.key});

  @override
  State<LiquidGlassDemoPage> createState() => _LiquidGlassDemoPageState();
}

class _LiquidGlassDemoPageState extends State<LiquidGlassDemoPage> {
  final TextEditingController _textController = TextEditingController(
    text: 'La Profecia',
  );
  final TextEditingController _textAreaController = TextEditingController(
    text: 'Aqui puedes escribir ideas para retos y preguntas premium.',
  );
  final TextEditingController _passwordController = TextEditingController();

  var _switchValue = true;
  var _sliderValue = 0.45;
  var _chipSelected = true;
  var _showSearchCancelButton = false;
  var _selectedMainTab = 0;
  var _selectedBottomTab = 0;
  var _selectedSideBarItem = 0;
  var _indicatorAlignment = 0.0;
  var _indicatorThickness = 0.6;
  var _indicatorVelocity = 0.25;
  String? _pickerValue = 'Parejas';

  static const _tabs = [
    LGTab(icon: CupertinoIcons.house_fill, label: 'Inicio'),
    LGTab(icon: CupertinoIcons.gamecontroller_fill, label: 'Partida'),
    LGTab(icon: CupertinoIcons.person_crop_circle, label: 'Perfil'),
  ];

  static const _bottomTabs = [
    LGBottomBarTab(label: 'Inicio', icon: CupertinoIcons.house_fill),
    LGBottomBarTab(label: 'Ranking', icon: CupertinoIcons.chart_bar_fill),
    LGBottomBarTab(label: 'Cuenta', icon: CupertinoIcons.person_fill),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _textAreaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showDemoDialog() async {
    await LGDialog.show<void>(
      context: context,
      title: 'Activar Modo Profecia',
      message: 'Esta accion habilita reglas premium solo para esta demo.',
      actions: [
        LGDialogAction(
          label: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        LGDialogAction(
          label: 'Activar',
          isPrimary: true,
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Modo Profecia activado (demo).')),
            );
          },
        ),
      ],
      settings: const LiquidGlassSettings(
        blur: 18,
        thickness: 28,
        glassColor: Color(0x40FFFFFF),
      ),
    );
  }

  Future<void> _showDemoSheet() async {
    await LGSheet.show<void>(
      context: context,
      settings: const LiquidGlassSettings(
        blur: 14,
        thickness: 24,
        glassColor: Color(0x33FFFFFF),
      ),
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.play_circle),
              title: const Text('Iniciar partida rapida'),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.star_fill),
              title: const Text('Ver niveles premium'),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.xmark_circle_fill),
              title: const Text('Cerrar'),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPickerSheet() async {
    final selected = await LGSheet.show<String>(
      context: context,
      builder: (sheetContext) {
        const options = ['Parejas', 'Amigos', 'Mixto'];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                title: Text(option),
                trailing: option == _pickerValue
                    ? const Icon(CupertinoIcons.check_mark)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _pickerValue = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: const LiquidGlassSettings(
        blur: 10,
        thickness: 22,
        saturation: 1.08,
        glassColor: Color(0x26FFFFFF),
      ),
      child: Scaffold(
        extendBody: true,
        appBar: LGAppBar(
          useOwnLayer: true,
          quality: LGQuality.standard,
          settings: const LiquidGlassSettings(
            blur: 20,
            thickness: 24,
            glassColor: Color(0x40FFFFFF),
          ),
          title: const Text(
            'Demo Liquid Glass+',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          leading: LGIconButton(
            icon: CupertinoIcons.back,
            size: 36,
            interactionScale: 1,
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            LGIconButton(
              icon: CupertinoIcons.bell_fill,
              size: 34,
              onPressed: _showDemoSheet,
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/background-home.png', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x88090514),
                    const Color(0xFF05020F).withValues(alpha: 0.98),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  180,
                ),
                children: [
                  const _DemoIntroCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSurfacesSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildControlsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFormsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildOverlaysSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCoreComponentsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurfacesSection() {
    return _DemoSection(
      title: 'Superficies',
      subtitle: 'LGAppBar, LGTabBar, LGBottomBar, LGSideBar, LGToolBar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LGPanel(
            useOwnLayer: true,
            quality: LGQuality.standard,
            settings: const LiquidGlassSettings(blur: 10, thickness: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LGTabBar(
                  tabs: _tabs,
                  selectedIndex: _selectedMainTab,
                  quality: LGQuality.standard,
                  useOwnLayer: true,
                  indicatorColor: Colors.white.withValues(alpha: 0.15),
                  onTabSelected: (index) {
                    setState(() {
                      _selectedMainTab = index;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tab actual: ${_tabs[_selectedMainTab].label}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 210,
            child: Row(
              children: [
                LGSideBar(
                  width: 150,
                  quality: LGQuality.standard,
                  children: [
                    for (var index = 0; index < _tabs.length; index++)
                      LGSideBarItem(
                        icon: index == 0
                            ? CupertinoIcons.house_fill
                            : index == 1
                            ? CupertinoIcons.square_grid_2x2_fill
                            : CupertinoIcons.person_fill,
                        label: _tabs[index].label ?? 'Item ${index + 1}',
                        isSelected: _selectedSideBarItem == index,
                        onTap: () {
                          setState(() {
                            _selectedSideBarItem = index;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: LGCard(
                    useOwnLayer: true,
                    quality: LGQuality.standard,
                    child: const Text(
                      'La SideBar funciona como navegación secundaria en layouts amplios.',
                      style: TextStyle(color: Colors.white, height: 1.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 130,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: LGBottomBar(
                tabs: _bottomTabs,
                selectedIndex: _selectedBottomTab,
                quality: LGQuality.standard,
                showLabel: true,
                searchPlaceholder: 'Buscar cartas...',
                onTabSelected: (index) {
                  setState(() {
                    _selectedBottomTab = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return _DemoSection(
      title: 'Botones y Controles',
      subtitle:
          'LGButton, LGIconButton, LGChip, LGSwitch, LGSlider, LGButtonGroup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              LGButton(
                icon: CupertinoIcons.play_fill,
                label: 'Jugar',
                width: 54,
                height: 54,
                quality: LGQuality.standard,
                onTap: () {},
              ),
              LGButton.custom(
                onTap: () {},
                width: 150,
                height: 54,
                quality: LGQuality.standard,
                style: LGButtonStyle.filled,
                child: const Text(
                  'Botón Custom',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              LGButton.custom(
                onTap: () {},
                width: 160,
                height: 54,
                quality: LGQuality.standard,
                style: LGButtonStyle.transparent,
                child: const Text(
                  'Estilo Transparente',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              LGIconButton(
                icon: CupertinoIcons.heart_fill,
                size: 46,
                quality: LGQuality.standard,
                onPressed: () {},
              ),
              LGIconButton(
                icon: CupertinoIcons.star_fill,
                shape: LGIconButtonShape.roundedSquare,
                quality: LGQuality.standard,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              LGChip(
                label: 'Premium',
                icon: CupertinoIcons.sparkles,
                selected: _chipSelected,
                quality: LGQuality.standard,
                onTap: () {
                  setState(() {
                    _chipSelected = !_chipSelected;
                  });
                },
              ),
              LGChip(
                label: 'Eliminar',
                icon: CupertinoIcons.trash,
                quality: LGQuality.standard,
                onDeleted: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('onDeleted ejecutado.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LGButtonGroup(
            direction: Axis.horizontal,
            quality: LGQuality.standard,
            children: [
              LGButton.custom(
                onTap: () {},
                style: LGButtonStyle.transparent,
                width: 84,
                height: 50,
                child: const Text('R1', style: TextStyle(color: Colors.white)),
              ),
              LGButton.custom(
                onTap: () {},
                style: LGButtonStyle.transparent,
                width: 84,
                height: 50,
                child: const Text('R2', style: TextStyle(color: Colors.white)),
              ),
              LGButton.custom(
                onTap: () {},
                style: LGButtonStyle.transparent,
                width: 84,
                height: 50,
                child: const Text('R3', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(
                child: Text('LGSwitch', style: TextStyle(color: Colors.white)),
              ),
              LGSwitch(
                value: _switchValue,
                quality: LGQuality.standard,
                onChanged: (value) {
                  setState(() {
                    _switchValue = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'LGSlider: ${(_sliderValue * 100).round()}%',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          LGSlider(
            value: _sliderValue,
            quality: LGQuality.standard,
            divisions: 10,
            label: 'Intensidad',
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormsSection() {
    return _DemoSection(
      title: 'Inputs y Formularios',
      subtitle:
          'LGTextField, LGTextArea, GlassPasswordField, LGSearchBar, LGPicker, LGFormField',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LGFormField(
            label: 'Nombre de jugador',
            helperText: 'Campo de ejemplo para perfil local.',
            child: LGTextField(
              controller: _textController,
              quality: LGQuality.standard,
              placeholder: 'Escribe un nombre...',
              prefixIcon: const Icon(
                CupertinoIcons.person_fill,
                color: Colors.white70,
                size: 18,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LGFormField(
            label: 'Password',
            child: GlassPasswordField(
              controller: _passwordController,
              quality: LGQuality.standard,
              placeholder: 'Clave premium',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LGFormField(
            label: 'Notas de moderación',
            child: LGTextArea(
              controller: _textAreaController,
              quality: LGQuality.standard,
              minLines: 3,
              maxLines: 6,
              placeholder: 'Describe la sugerencia...',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LGSearchBar(
            quality: LGQuality.standard,
            placeholder: 'Buscar retos por texto...',
            showsCancelButton: _showSearchCancelButton,
            onChanged: (_) {},
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mostrar botón Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Switch.adaptive(
                value: _showSearchCancelButton,
                onChanged: (value) {
                  setState(() {
                    _showSearchCancelButton = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LGFormField(
            label: 'Modo de juego',
            errorText: _pickerValue == null ? 'Selecciona un modo.' : null,
            child: LGPicker(
              value: _pickerValue,
              quality: LGQuality.standard,
              placeholder: 'Seleccionar modo',
              onTap: _showPickerSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlaysSection() {
    return _DemoSection(
      title: 'Overlays',
      subtitle: 'LGDialog, LGSheet, LGMenu y LGMenuItem',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              LGButton.custom(
                onTap: _showDemoDialog,
                quality: LGQuality.standard,
                width: 160,
                height: 52,
                child: const Text(
                  'Abrir LGDialog',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              LGButton.custom(
                onTap: _showDemoSheet,
                quality: LGQuality.standard,
                width: 160,
                height: 52,
                child: const Text(
                  'Abrir LGSheet',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: LGMenu(
              menuWidth: 230,
              quality: LGQuality.standard,
              triggerBuilder: (context, toggleMenu) {
                return LGButton.custom(
                  onTap: toggleMenu,
                  quality: LGQuality.standard,
                  width: 220,
                  height: 50,
                  child: const Text(
                    'Abrir LGMenu',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
              items: [
                LGMenuItem(
                  title: 'Editar carta',
                  icon: CupertinoIcons.pencil,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Editar carta')),
                    );
                  },
                ),
                LGMenuItem(
                  title: 'Duplicar',
                  icon: CupertinoIcons.doc_on_doc,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Duplicar elemento')),
                    );
                  },
                ),
                LGMenuItem(
                  title: 'Eliminar',
                  icon: CupertinoIcons.trash,
                  isDestructive: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Eliminar (demo)')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreComponentsSection() {
    return _DemoSection(
      title: 'Componentes Base',
      subtitle:
          'LGCard, LGContainer, LGPanel, LGIndicator y capas grouped/ownLayer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LGCard(
            quality: LGQuality.standard,
            child: const Text(
              'LGCard usa estilo de caja con padding listo para contenido.',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: LGContainer(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  quality: LGQuality.standard,
                  child: const Text(
                    'Grouped',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: LGContainer(
                  useOwnLayer: true,
                  quality: LGQuality.standard,
                  settings: const LiquidGlassSettings(blur: 20, thickness: 32),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: const Text(
                    'useOwnLayer',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LGPanel(
            quality: LGQuality.standard,
            useOwnLayer: true,
            child: const Text(
              'LGPanel está orientado a superficies grandes: modales, paneles, bloques de configuración.',
              style: TextStyle(color: Colors.white, height: 1.35),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'LGIndicator (align=${_indicatorAlignment.toStringAsFixed(2)}, thickness=${_indicatorThickness.toStringAsFixed(2)}, velocity=${_indicatorVelocity.toStringAsFixed(2)})',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 66,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                LGIndicator(
                  velocity: _indicatorVelocity,
                  itemCount: 3,
                  alignment: Alignment(_indicatorAlignment, 0),
                  thickness: _indicatorThickness,
                  quality: LGQuality.standard,
                  indicatorColor: Colors.white.withValues(alpha: 0.20),
                  borderRadius: 20,
                  isBackgroundIndicator: true,
                ),
                LGIndicator(
                  velocity: _indicatorVelocity,
                  itemCount: 3,
                  alignment: Alignment(_indicatorAlignment, 0),
                  thickness: _indicatorThickness,
                  quality: LGQuality.standard,
                  indicatorColor: Colors.white.withValues(alpha: 0.20),
                  borderRadius: 20,
                  isBackgroundIndicator: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text('Alineación', style: TextStyle(color: Colors.white70)),
          Slider(
            value: _indicatorAlignment,
            min: -1,
            max: 1,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _indicatorAlignment = value;
              });
            },
          ),
          const Text('Thickness', style: TextStyle(color: Colors.white70)),
          Slider(
            value: _indicatorThickness,
            min: 0,
            max: 1,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _indicatorThickness = value;
              });
            },
          ),
          const Text('Velocity', style: TextStyle(color: Colors.white70)),
          Slider(
            value: _indicatorVelocity,
            min: -1,
            max: 1,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _indicatorVelocity = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _DemoIntroCard extends StatelessWidget {
  const _DemoIntroCard();

  @override
  Widget build(BuildContext context) {
    return LGContainer(
      useOwnLayer: true,
      quality: LGQuality.standard,
      settings: const LiquidGlassSettings(
        blur: 20,
        thickness: 28,
        glassColor: Color(0x2EFFFFFF),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cobertura de funcionalidades',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Esta vista reúne los widgets principales del paquete flutter_liquid_glass_plus para revisar API, interacción y estilo en un único flujo.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LGContainer(
      useOwnLayer: true,
      quality: LGQuality.standard,
      settings: const LiquidGlassSettings(
        blur: 16,
        thickness: 24,
        glassColor: Color(0x26FFFFFF),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
