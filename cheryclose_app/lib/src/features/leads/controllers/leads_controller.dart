import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../data/leads_repository.dart';
import '../../../domain/models/entities.dart';

final leadsListProvider = FutureProvider<List<Lead>>((ref) async {
  final repo = ref.watch(leadsRepositoryProvider);
  return repo.getLeads();
});

final leadStages = LeadStage.values;

class LeadsNotifier extends StateNotifier<AsyncValue<List<Lead>>> {
  LeadsNotifier(this._read)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _read;

  LeadsRepository get _repo => _read.read(leadsRepositoryProvider);

  Future<void> _load() async {
    try {
      final leads = await _repo.getLeads();
      state = AsyncValue.data(leads);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addLead({
    required String name,
    required String phone,
    required String modelInterest,
    required String source,
    required bool consent,
    String notes = '',
  }) async {
    if (!consent) {
      throw StateError('Consent required');
    }
    state = const AsyncValue.loading();
    try {
      await _repo.addLead(
        name: name,
        phone: phone,
        modelInterest: modelInterest,
        source: source,
        consentMarketing: consent,
        notes: notes,
      );
      await _load();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateLead(Lead lead) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateLead(lead);
      await _load();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteLead(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteLead(id);
      await _load();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final leadsNotifierProvider =
    StateNotifierProvider<LeadsNotifier, AsyncValue<List<Lead>>>((ref) {
  return LeadsNotifier(ref);
});
