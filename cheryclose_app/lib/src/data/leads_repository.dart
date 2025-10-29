import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/entities.dart';

class LeadsRepository {
  LeadsRepository({
    required this.userId,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final String userId;
  final Uuid _uuid;

  List<Lead> _leads = const [];
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final file = await _file;
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final json = jsonDecode(content) as List<dynamic>;
        _leads = json
            .map((item) => Lead.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
      }
    }
    _initialized = true;
  }

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/leads_$userId.json';
    return File(path);
  }

  Future<List<Lead>> getLeads() async {
    await _ensureInitialized();
    return _leads;
  }

  Future<Lead> addLead({
    required String name,
    required String phone,
    required String modelInterest,
    required String source,
    required bool consentMarketing,
    String notes = '',
  }) async {
    await _ensureInitialized();
    final lead = Lead(
      id: _uuid.v4(),
      ownerUserId: userId,
      name: name,
      phone: phone,
      modelInterest: modelInterest,
      source: source,
      consentMarketing: consentMarketing,
      notes: notes,
    );
    _leads = [..._leads, lead];
    await _persist();
    return lead;
  }

  Future<void> updateLead(Lead lead) async {
    await _ensureInitialized();
    _leads = [
      for (final item in _leads) if (item.id == lead.id) lead else item
    ];
    await _persist();
  }

  Future<void> deleteLead(String id) async {
    await _ensureInitialized();
    _leads = _leads.where((lead) => lead.id != id).toList(growable: false);
    await _persist();
  }

  Future<void> clear() async {
    _leads = const [];
    final file = await _file;
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _persist() async {
    final file = await _file;
    final data = jsonEncode(_leads.map((lead) => lead.toJson()).toList());
    await file.writeAsString(data, flush: true);
  }
}
