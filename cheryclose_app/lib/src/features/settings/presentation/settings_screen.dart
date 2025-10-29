import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController numberController;
  late TextEditingController rateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    numberController = TextEditingController();
    rateController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsState.when(
        data: (settings) {
          nameController.text = settings.displayName;
          numberController.text = settings.whatsappNumber;
          rateController.text = settings.defaultInterestRate.toString();
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Display name for footer'),
                  validator: _required,
                ),
                TextFormField(
                  controller: numberController,
                  decoration:
                      const InputDecoration(labelText: 'WhatsApp number (+27...)'),
                  validator: _required,
                ),
                TextFormField(
                  controller: rateController,
                  decoration: const InputDecoration(
                    labelText: 'Default interest rate %',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _required,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final controller =
                        ref.read(settingsControllerProvider.notifier);
                    await controller.update(
                      settings.copyWith(
                        displayName: nameController.text,
                        whatsappNumber: numberController.text,
                        defaultInterestRate:
                            double.tryParse(rateController.text) ?? 12.5,
                      ),
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings saved')),
                    );
                  },
                  child: const Text('Save settings'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    return null;
  }
}
