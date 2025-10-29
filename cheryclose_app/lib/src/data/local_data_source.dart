import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/models/entities.dart';

class LocalContentDataSource {
  const LocalContentDataSource();

  Future<List<VehicleModel>> loadVehicleModels() async {
    final raw = await rootBundle.loadString('assets/models/models.json');
    return decodeList(raw, VehicleModel.fromJson);
  }

  Future<List<CaptionTemplate>> loadCaptions() async {
    final raw = await rootBundle.loadString('assets/captions/captions.json');
    return decodeList(raw, CaptionTemplate.fromJson);
  }

  Future<TemplatesBundle> loadTemplates() async {
    final raw = await rootBundle.loadString('assets/templates.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final followUpPlans = (json['followUpPlans'] as List<dynamic>)
        .map((e) => FollowUpPlan.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    final messageTemplates = (json['messageTemplates'] as List<dynamic>)
        .map((e) => MessageTemplate.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    final objections = (json['objections'] as List<dynamic>)
        .map((e) => ObjectionScript.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return TemplatesBundle(
      followUpPlans: followUpPlans,
      messageTemplates: messageTemplates,
      objections: objections,
    );
  }
}

class TemplatesBundle {
  const TemplatesBundle({
    required this.followUpPlans,
    required this.messageTemplates,
    required this.objections,
  });

  final List<FollowUpPlan> followUpPlans;
  final List<MessageTemplate> messageTemplates;
  final List<ObjectionScript> objections;
}
