import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/suggestion.dart';
import '../providers/suggestions_providers.dart';

class SuggestionsPage extends ConsumerStatefulWidget {
  const SuggestionsPage({super.key});

  @override
  ConsumerState<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends ConsumerState<SuggestionsPage> {
  final TextEditingController _contentController = TextEditingController();
  SuggestionType _type = SuggestionType.question;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(suggestionsControllerProvider);
    final ok = await controller.submit(
      type: _type,
      content: _contentController.text,
    );
    if (!mounted) {
      return;
    }
    final message = controller.message;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (ok) {
      _contentController.clear();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(suggestionsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Proponer contenido')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            DropdownButtonFormField<SuggestionType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: SuggestionType.values
                  .map(
                    (item) => DropdownMenuItem<SuggestionType>(
                      value: item,
                      child: Text(item.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _type = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _contentController,
              minLines: 5,
              maxLines: 8,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Tu propuesta',
                hintText: 'Escribe una pregunta o reto para revision.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: controller.isLoading ? null : _submit,
                child: controller.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar sugerencia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
