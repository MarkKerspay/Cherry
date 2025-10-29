import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../data/local_data_source.dart';
import '../../../domain/models/entities.dart';
import '../controllers/leads_controller.dart';
import '../widgets/lead_form_dialog.dart';

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsState = ref.watch(leadsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const LeadFormDialog(),
        ),
        child: const Icon(Icons.add),
      ),
      body: leadsState.when(
        data: (leads) {
          if (leads.isEmpty) {
            return const Center(
              child: Text('No leads yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return ListTile(
                title: Text(lead.name),
                subtitle: Text('${lead.modelInterest} • ${lead.stage.name}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'advance':
                        final nextStage = _nextStage(lead.stage);
                        await ref
                            .read(leadsNotifierProvider.notifier)
                            .updateLead(lead.copyWith(stage: nextStage));
                        break;
                      case 'delete':
                        await ref
                            .read(leadsNotifierProvider.notifier)
                            .deleteLead(lead.id);
                        break;
                      case 'followup':
                        await _openFollowUpDialog(context, ref, lead);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (lead.stage != LeadStage.deal)
                      const PopupMenuItem(
                        value: 'advance',
                        child: Text('Advance stage'),
                      ),
                    const PopupMenuItem(
                      value: 'followup',
                      child: Text('Assign follow-up'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
                onTap: () => _openLeadDetails(context, lead),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  LeadStage _nextStage(LeadStage stage) {
    final index = LeadStage.values.indexOf(stage);
    if (index + 1 < LeadStage.values.length) {
      return LeadStage.values[index + 1];
    }
    return stage;
  }

  Future<void> _openFollowUpDialog(
    BuildContext context,
    WidgetRef ref,
    Lead lead,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FollowUpPlanner(lead: lead),
    );
  }

  void _openLeadDetails(BuildContext context, Lead lead) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(lead.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone: ${lead.phone}'),
              Text('Model: ${lead.modelInterest}'),
              Text('Stage: ${lead.stage.name}'),
              if (lead.nextActionAt != null)
                Text('Next action: ${lead.nextActionAt}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class FollowUpPlanner extends ConsumerWidget {
  const FollowUpPlanner({required this.lead, super.key});

  final Lead lead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);
    return templates.when(
      data: (bundle) {
        final plans = bundle.followUpPlans;
        final templatesMap = {
          for (final template in bundle.messageTemplates)
            template.id: template
        };
        FollowUpPlan? selectedPlan = lead.followUpPlanId != null
            ? plans.firstWhere(
                (plan) => plan.id == lead.followUpPlanId,
                orElse: () => plans.first,
              )
            : plans.first;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign follow-up',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<FollowUpPlan>(
                    isExpanded: true,
                    value: selectedPlan,
                    items: [
                      for (final plan in plans)
                        DropdownMenuItem(
                          value: plan,
                          child: Text(plan.name),
                        )
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedPlan = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedPlan != null)
                    ...selectedPlan!.steps.map((step) {
                      final template = templatesMap[step.templateId];
                      return ListTile(
                        title: Text('Day ${step.dayOffset}'),
                        subtitle: Text(template?.name ?? step.templateId),
                      );
                    }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final notifier = ref.read(leadsNotifierProvider.notifier);
                      final nextAction = selectedPlan!.steps
                          .map((step) => DateTime.now().add(
                                Duration(days: step.dayOffset),
                              ))
                          .reduce((value, element) =>
                              value.isBefore(element) ? value : element);
                      await notifier.updateLead(
                        lead.copyWith(
                          followUpPlanId: selectedPlan!.id,
                          nextActionAt: nextAction,
                        ),
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Save plan'),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading plans: $error'),
      ),
    );
  }
}

final templatesProvider = FutureProvider((ref) async {
  final bundle = await ref.watch(localContentDataSourceProvider).loadTemplates();
  return bundle;
});
