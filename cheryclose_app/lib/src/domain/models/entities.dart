import 'dart:convert';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.name,
    required this.image,
    required this.basePrice,
    required this.warranty,
    required this.keyBullets,
    required this.hybridNotes,
    required this.rivalCompare,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      warranty: json['warranty'] as String,
      keyBullets: List<String>.from(json['keyBullets'] as List<dynamic>),
      hybridNotes: json['hybridNotes'] as String,
      rivalCompare: List<RivalComparison>.from(
        (json['rivalCompare'] as List<dynamic>).map(
          (item) => RivalComparison.fromJson(item as Map<String, dynamic>),
        ),
      ),
    );
  }

  final String id;
  final String name;
  final String image;
  final double basePrice;
  final String warranty;
  final List<String> keyBullets;
  final String hybridNotes;
  final List<RivalComparison> rivalCompare;
}

class RivalComparison {
  const RivalComparison({required this.rival, required this.bullet});

  factory RivalComparison.fromJson(Map<String, dynamic> json) {
    return RivalComparison(
      rival: json['rival'] as String,
      bullet: json['bullet'] as String,
    );
  }

  final String rival;
  final String bullet;
}

class CaptionTemplate {
  const CaptionTemplate({
    required this.id,
    required this.modelId,
    required this.title,
    required this.body,
  });

  factory CaptionTemplate.fromJson(Map<String, dynamic> json) {
    return CaptionTemplate(
      id: json['id'] as String,
      modelId: json['modelId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  final String id;
  final String modelId;
  final String title;
  final String body;
}

class FollowUpPlan {
  const FollowUpPlan({required this.id, required this.name, required this.steps});

  factory FollowUpPlan.fromJson(Map<String, dynamic> json) {
    return FollowUpPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      steps: List<FollowUpStep>.from(
        (json['steps'] as List<dynamic>).map(
          (e) => FollowUpStep.fromJson(e as Map<String, dynamic>),
        ),
      ),
    );
  }

  final String id;
  final String name;
  final List<FollowUpStep> steps;
}

class FollowUpStep {
  const FollowUpStep({required this.dayOffset, required this.templateId});

  factory FollowUpStep.fromJson(Map<String, dynamic> json) {
    return FollowUpStep(
      dayOffset: json['dayOffset'] as int,
      templateId: json['templateId'] as String,
    );
  }

  final int dayOffset;
  final String templateId;
}

class MessageTemplate {
  const MessageTemplate({
    required this.id,
    required this.name,
    required this.body,
    required this.tone,
  });

  factory MessageTemplate.fromJson(Map<String, dynamic> json) {
    return MessageTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      body: json['body'] as String,
      tone: json['tone'] as String,
    );
  }

  final String id;
  final String name;
  final String body;
  final String tone;
}

class ObjectionScript {
  const ObjectionScript({required this.id, required this.title, required this.body});

  factory ObjectionScript.fromJson(Map<String, dynamic> json) {
    return ObjectionScript(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  final String id;
  final String title;
  final String body;
}

class Lead {
  Lead({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.phone,
    required this.modelInterest,
    required this.source,
    required this.consentMarketing,
    this.notes = '',
    this.followUpPlanId,
    this.stage = LeadStage.newLead,
    this.nextActionAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      ownerUserId: json['ownerUserId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      modelInterest: json['modelInterest'] as String,
      source: json['source'] as String,
      consentMarketing: json['consentMarketing'] as bool,
      notes: json['notes'] as String? ?? '',
      followUpPlanId: json['followUpPlanId'] as String?,
      stage: LeadStage.values.byName(json['stage'] as String),
      nextActionAt: json['nextActionAt'] != null
          ? DateTime.parse(json['nextActionAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String ownerUserId;
  final String name;
  final String phone;
  final String modelInterest;
  final String source;
  final bool consentMarketing;
  final String notes;
  final String? followUpPlanId;
  final LeadStage stage;
  final DateTime? nextActionAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lead copyWith({
    String? name,
    String? phone,
    String? modelInterest,
    String? source,
    bool? consentMarketing,
    String? notes,
    String? followUpPlanId,
    LeadStage? stage,
    DateTime? nextActionAt,
    DateTime? updatedAt,
  }) {
    return Lead(
      id: id,
      ownerUserId: ownerUserId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      modelInterest: modelInterest ?? this.modelInterest,
      source: source ?? this.source,
      consentMarketing: consentMarketing ?? this.consentMarketing,
      notes: notes ?? this.notes,
      followUpPlanId: followUpPlanId ?? this.followUpPlanId,
      stage: stage ?? this.stage,
      nextActionAt: nextActionAt ?? this.nextActionAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'name': name,
      'phone': phone,
      'modelInterest': modelInterest,
      'source': source,
      'consentMarketing': consentMarketing,
      'notes': notes,
      'followUpPlanId': followUpPlanId,
      'stage': stage.name,
      'nextActionAt': nextActionAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum LeadStage { newLead, contacted, testdrive, deal, lost }

class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.date,
    required this.shares,
    required this.leadsCaptured,
    required this.testDrivesBooked,
    required this.dealsMarked,
  });

  AnalyticsSnapshot combine(AnalyticsSnapshot other) {
    return AnalyticsSnapshot(
      date: date,
      shares: shares + other.shares,
      leadsCaptured: leadsCaptured + other.leadsCaptured,
      testDrivesBooked: testDrivesBooked + other.testDrivesBooked,
      dealsMarked: dealsMarked + other.dealsMarked,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'shares': shares,
        'leadsCaptured': leadsCaptured,
        'testDrivesBooked': testDrivesBooked,
        'dealsMarked': dealsMarked,
      };

  factory AnalyticsSnapshot.fromJson(Map<String, dynamic> json) {
    return AnalyticsSnapshot(
      date: DateTime.parse(json['date'] as String),
      shares: json['shares'] as int,
      leadsCaptured: json['leadsCaptured'] as int,
      testDrivesBooked: json['testDrivesBooked'] as int,
      dealsMarked: json['dealsMarked'] as int,
    );
  }

  final DateTime date;
  final int shares;
  final int leadsCaptured;
  final int testDrivesBooked;
  final int dealsMarked;
}

List<T> decodeList<T>(String source, T Function(Map<String, dynamic>) factory) {
  final raw = jsonDecode(source) as List<dynamic>;
  return raw
      .map((item) => factory(item as Map<String, dynamic>))
      .toList(growable: false);
}
