import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/entities.dart';
import '../../share/controllers/share_controller.dart';
import '../controllers/leads_controller.dart';

class LeadFormDialog extends ConsumerStatefulWidget {
  const LeadFormDialog({super.key});

  @override
  ConsumerState<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends ConsumerState<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _modelInterest = 'Tiggo 4 Pro';
  bool _consent = false;
  String _source = 'whatsapp';
  bool _initialisedModel = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shareContent = ref.watch(shareContentProvider);
    return AlertDialog(
      title: const Text('New lead'),
      content: shareContent.when(
        data: (data) {
          if (!_initialisedModel && data.models.isNotEmpty) {
            _modelInterest = data.models.first.name;
            _initialisedModel = true;
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration:
                        const InputDecoration(labelText: 'WhatsApp number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _modelInterest,
                    decoration: const InputDecoration(labelText: 'Model'),
                    items: [
                      for (final model in data.models)
                        DropdownMenuItem(
                          value: model.name,
                          child: Text(model.name),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _modelInterest = value);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _source,
                    decoration: const InputDecoration(labelText: 'Source'),
                    items: const [
                      DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                      DropdownMenuItem(value: 'poster', child: Text('Poster QR')),
                      DropdownMenuItem(value: 'walkin', child: Text('Walk-in')),
                      DropdownMenuItem(value: 'status', child: Text('Status view')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _source = value);
                    },
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  CheckboxListTile(
                    value: _consent,
                    onChanged: (value) => setState(() => _consent = value ?? false),
                    title: const Text('Lead consented to WhatsApp follow-up'),
                    subtitle: const Text('Required for POPIA compliance.'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => SizedBox(
          height: 160,
          child: Center(child: Text('Error: $error')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            try {
              await ref.read(leadsNotifierProvider.notifier).addLead(
                    name: _nameController.text,
                    phone: _phoneController.text,
                    modelInterest: _modelInterest,
                    source: _source,
                    consent: _consent,
                    notes: _notesController.text,
                  );
              if (mounted) Navigator.of(context).pop();
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: const Text('Save lead'),
        ),
      ],
    );
  }
}
