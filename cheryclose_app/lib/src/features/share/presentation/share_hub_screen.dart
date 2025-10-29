import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/entities.dart';
import '../controllers/share_controller.dart';
import 'share_model_sheet.dart';

class ShareHubScreen extends ConsumerWidget {
  const ShareHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(shareContentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share to WhatsApp'),
      ),
      body: content.when(
        data: (data) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.models.length,
          itemBuilder: (context, index) {
            final model = data.models[index];
            return _ModelCard(
              model: model,
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ShareModelSheet(
                  model: model,
                  captions: data.captionsForModel(model.id),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.model, required this.onTap});

  final VehicleModel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(model.name),
        subtitle: Text('From R${model.basePrice.toStringAsFixed(0)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
