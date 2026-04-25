import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import '../../domain/entities/editable_profile.dart';

typedef EditableProfileSaveCallback =
    Future<EditableProfile> Function({
      required String displayName,
      required ProfileIdentity identity,
      required ProfileAttraction attraction,
    });

class EditableProfileDialog extends StatefulWidget {
  const EditableProfileDialog({
    required this.initialProfile,
    required this.avatarAssetPath,
    required this.onSave,
    this.title = 'Editar jugador',
    this.saveButtonLabel = 'Guardar cambios',
    this.identityHelpText =
        'Elige como te identificas. Esto ayuda a personalizar preguntas y dinamicas.',
    this.attractionHelpText =
        'Elige que genero te atrae para adaptar preguntas y retos segun compatibilidad.',
    this.showIdentitySection = true,
    this.showAttractionSection = true,
    super.key,
  });

  final EditableProfile initialProfile;
  final String avatarAssetPath;
  final EditableProfileSaveCallback onSave;
  final String title;
  final String saveButtonLabel;
  final String identityHelpText;
  final String attractionHelpText;
  final bool showIdentitySection;
  final bool showAttractionSection;

  @override
  State<EditableProfileDialog> createState() => _EditableProfileDialogState();
}

class _EditableProfileDialogState extends State<EditableProfileDialog> {
  late final TextEditingController _nameController;
  ProfileIdentity? _identity;
  ProfileAttraction? _attraction;
  var _saving = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialProfile.displayName,
    );
    _identity = widget.initialProfile.identity;
    _attraction = widget.initialProfile.attraction;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _inlineError = 'Ingresa un nombre.';
      });
      return;
    }
    final requiresIdentity = widget.showIdentitySection;
    final requiresAttraction = widget.showAttractionSection;
    if ((requiresIdentity && _identity == null) ||
        (requiresAttraction && _attraction == null)) {
      setState(() {
        _inlineError = 'Selecciona como te identificas y que te atrae.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _inlineError = null;
    });
    try {
      final identityForSave =
          _identity ?? widget.initialProfile.identity ?? ProfileIdentity.man;
      final attractionForSave =
          _attraction ??
          widget.initialProfile.attraction ??
          ProfileAttraction.both;
      final updated = await widget.onSave(
        displayName: name,
        identity: identityForSave,
        attraction: attractionForSave,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(updated);
    } catch (error) {
      final message = error is AppFailure
          ? error.message
          : 'No se pudo guardar los cambios.';
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _inlineError = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final displayName = _nameController.text.trim();
    final shownName = displayName.isEmpty ? 'Jugador' : displayName;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: PremiumGlassSurface(
          borderRadius: BorderRadius.circular(34),
          gradientColors: [
            const Color(0xFF0D1019).withValues(alpha: 0.97),
            const Color(0xFF05070D).withValues(alpha: 0.99),
          ],
          borderColor: Colors.white.withValues(alpha: 0.16),
          innerBorderColor: Colors.white.withValues(alpha: 0.05),
          topHighlightOpacity: 0.06,
          bottomShadeOpacity: 0.20,
          outerShadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 42,
              offset: const Offset(0, 18),
            ),
          ],
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : MediaQuery.sizeOf(context).height * 0.9;
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 132,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.white.withValues(alpha: 0.66),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Text(
                                  widget.title,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.94,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const Spacer(),
                                _CloseCircleButton(
                                  enabled: !_saving,
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(94),
                                    color: Colors.black.withValues(alpha: 0.25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(94),
                                    child: Image.asset(
                                      widget.avatarAssetPath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    shownName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.95,
                                          ),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 34 * 0.62,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Nombre *',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.90),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 34 * 0.54,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _NameInputField(
                              controller: _nameController,
                              enabled: !_saving,
                              onChanged: (_) => setState(() {}),
                            ),
                            if (widget.showIdentitySection) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _SectionLabelWithHint(
                                title: 'Como te identificas?',
                                helpText: widget.identityHelpText,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _ChoiceRow<ProfileIdentity>(
                                options: ProfileIdentity.values
                                    .map(
                                      (item) => _DialogOption<ProfileIdentity>(
                                        value: item,
                                        label: item.label,
                                        assetPath: item.iconAssetPath,
                                      ),
                                    )
                                    .toList(growable: false),
                                selected: _identity,
                                onChanged: _saving
                                    ? null
                                    : (value) =>
                                          setState(() => _identity = value),
                              ),
                            ],
                            if (widget.showAttractionSection) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _SectionLabelWithHint(
                                title: 'Que te atrae?',
                                helpText: widget.attractionHelpText,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _ChoiceRow<ProfileAttraction>(
                                options: ProfileAttraction.values
                                    .map(
                                      (item) =>
                                          _DialogOption<ProfileAttraction>(
                                            value: item,
                                            label: item.label,
                                            assetPath: item.iconAssetPath,
                                          ),
                                    )
                                    .toList(growable: false),
                                selected: _attraction,
                                onChanged: _saving
                                    ? null
                                    : (value) =>
                                          setState(() => _attraction = value),
                              ),
                            ],
                            if (_inlineError != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _inlineError!,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(color: const Color(0xFFFF7C77)),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: _SaveButton(
                                label: widget.saveButtonLabel,
                                loading: _saving,
                                onTap: _saving ? null : _save,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.95),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        hintText: 'Nombre',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.40)),
        filled: true,
        fillColor: const Color(0xFF0C1018).withValues(alpha: 0.76),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: const Color(0xFF3DA0FF).withValues(alpha: 0.58),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF3DA0FF), width: 1.4),
        ),
      ),
    );
  }
}

class _SectionLabelWithHint extends StatelessWidget {
  const _SectionLabelWithHint({required this.title, required this.helpText});

  final String title;
  final String helpText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
            fontSize: 34 * 0.50,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: helpText,
          triggerMode: TooltipTriggerMode.tap,
          waitDuration: Duration.zero,
          showDuration: const Duration(seconds: 5),
          preferBelow: false,
          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.info_rounded,
            color: Colors.white.withValues(alpha: 0.72),
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _DialogOption<T> {
  const _DialogOption({
    required this.value,
    required this.label,
    required this.assetPath,
  });

  final T value;
  final String label;
  final String assetPath;
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<_DialogOption<T>> options;
  final T? selected;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: item == options.last ? 0 : AppSpacing.sm,
                ),
                child: _ChoiceButton(
                  label: item.label,
                  assetPath: item.assetPath,
                  selected: selected == item.value,
                  enabled: onChanged != null,
                  onTap: onChanged == null
                      ? null
                      : () => onChanged!(item.value),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.assetPath,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: PremiumGlassSurface(
          height: 52,
          borderRadius: BorderRadius.circular(20),
          gradientColors: selected
              ? [
                  const Color(0xFF4EA9FF).withValues(alpha: 0.94),
                  const Color(0xFF235C9A).withValues(alpha: 0.98),
                ]
              : [
                  const Color(0xFF19202C).withValues(alpha: 0.90),
                  const Color(0xFF0E131C).withValues(alpha: 0.98),
                ],
          borderColor: selected
              ? const Color(0xFF7ECBFF).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.24),
          innerBorderColor: Colors.white.withValues(
            alpha: selected ? 0.14 : 0.07,
          ),
          topHighlightOpacity: selected ? 0.18 : 0.10,
          bottomShadeOpacity: selected ? 0.14 : 0.20,
          outerShadows: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF2A6FB9).withValues(alpha: 0.32)
                  : Colors.black.withValues(alpha: 0.26),
              blurRadius: 18,
              spreadRadius: -6,
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 13,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.94),
                  fontWeight: FontWeight.w500,
                  fontSize: 31 * 0.43,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PremiumGlassSurface(
        height: 58,
        borderRadius: BorderRadius.circular(26),
        gradientColors: [
          const Color(0xFF57B4FF).withValues(alpha: 0.95),
          const Color(0xFF1E5E9D).withValues(alpha: 0.98),
        ],
        borderColor: const Color(0xFF82CDFF).withValues(alpha: 0.95),
        innerBorderColor: Colors.white.withValues(alpha: 0.16),
        topHighlightOpacity: 0.19,
        bottomShadeOpacity: 0.16,
        outerShadows: [
          BoxShadow(
            color: const Color(0xFF1D5B97).withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: -8,
          ),
        ],
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.96),
                    fontWeight: FontWeight.w700,
                    fontSize: 38 * 0.54,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CloseCircleButton extends StatelessWidget {
  const _CloseCircleButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.13),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
        ),
        child: Icon(
          Icons.close_rounded,
          color: Colors.white.withValues(alpha: 0.92),
          size: 28,
        ),
      ),
    );
  }
}
