import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/entities.dart';
import '../../leads/controllers/leads_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsState = ref.watch(leadsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: leadsState.when(
        data: (leads) {
          final totals = _computeTotals(leads);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MetricCard(
                label: 'Leads captured',
                value: totals.leadsCaptured.toString(),
              ),
              _MetricCard(
                label: 'Follow-ups scheduled',
                value: totals.followUpsScheduled.toString(),
              ),
              _MetricCard(
                label: 'Deals won',
                value: totals.dealsWon.toString(),
              ),
              _MetricCard(
                label: 'Test drives booked',
                value: totals.testDrives.toString(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  _LeadTotals _computeTotals(List<Lead> leads) {
    final leadsCaptured = leads.length;
    final dealsWon =
        leads.where((lead) => lead.stage == LeadStage.deal).length;
    final testDrives =
        leads.where((lead) => lead.stage == LeadStage.testdrive).length;
    final followUpsScheduled =
        leads.where((lead) => lead.followUpPlanId != null).length;
    return _LeadTotals(
      leadsCaptured: leadsCaptured,
      dealsWon: dealsWon,
      testDrives: testDrives,
      followUpsScheduled: followUpsScheduled,
    );
  }
}

class _LeadTotals {
  const _LeadTotals({
    required this.leadsCaptured,
    required this.dealsWon,
    required this.testDrives,
    required this.followUpsScheduled,
  });

  final int leadsCaptured;
  final int dealsWon;
  final int testDrives;
  final int followUpsScheduled;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
