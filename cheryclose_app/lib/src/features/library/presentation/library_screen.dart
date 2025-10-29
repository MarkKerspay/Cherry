import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local_data_source.dart';
import '../../../domain/models/entities.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final dataSource = ref.watch(localContentDataSourceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: FutureBuilder<LibraryData>(
        future: _loadLibrary(dataSource),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Unable to load library'));
          }
          final models = snapshot.data!.models;
          final bundle = snapshot.data!.bundle;
          final searchLower = query.toLowerCase();
          final filteredModels = models
              .where((model) => model.name.toLowerCase().contains(searchLower))
              .toList();
          final filteredObjections = bundle.objections
              .where((item) => item.title.toLowerCase().contains(searchLower))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search library',
                  ),
                  onChanged: (value) => setState(() => query = value),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Text('Models', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...filteredModels.map((model) => _ModelCard(model: model)),
                    const SizedBox(height: 16),
                    Text('Objection replies',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...filteredObjections.map(
                      (objection) => Card(
                        child: ListTile(
                          title: Text(objection.title),
                          subtitle: Text(objection.body),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Message templates',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...bundle.messageTemplates.map(
                      (template) => Card(
                        child: ListTile(
                          title: Text(template.name),
                          subtitle: Text(template.body),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<LibraryData> _loadLibrary(LocalContentDataSource dataSource) async {
  final models = await dataSource.loadVehicleModels();
  final bundle = await dataSource.loadTemplates();
  return LibraryData(models: models, bundle: bundle);
}

class LibraryData {
  LibraryData({required this.models, required this.bundle});

  final List<VehicleModel> models;
  final TemplatesBundle bundle;
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.model});

  final VehicleModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('From R${model.basePrice.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Text('Warranty: ${model.warranty}'),
            const SizedBox(height: 8),
            Text('Key bullets:'),
            for (final bullet in model.keyBullets)
              Text('• $bullet', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Hybrid notes: ${model.hybridNotes}'),
          ],
        ),
      ),
    );
  }
}
