import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leads_repository.dart';
import '../data/local_data_source.dart';

final localContentDataSourceProvider = Provider<LocalContentDataSource>((ref) {
  return const LocalContentDataSource();
});

final leadsRepositoryProvider = Provider<LeadsRepository>((ref) {
  const mockUserId = 'demo-sales';
  return LeadsRepository(userId: mockUserId);
});
