import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers.dart';
import '../../../domain/models/entities.dart';

final shareContentProvider = FutureProvider<ShareContent>((ref) async {
  final dataSource = ref.watch(localContentDataSourceProvider);
  final models = await dataSource.loadVehicleModels();
  final captions = await dataSource.loadCaptions();
  return ShareContent(models: models, captions: captions);
});

class ShareContent {
  ShareContent({required this.models, required this.captions});

  final List<VehicleModel> models;
  final List<CaptionTemplate> captions;

  List<CaptionTemplate> captionsForModel(String modelId) {
    return captions.where((caption) => caption.modelId == modelId).toList();
  }
}

Future<void> shareCaption({required String caption, String? subject}) {
  return Share.share(caption, subject: subject);
}
