import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/progress_repository.dart';

final progressRepositoryProvider = Provider((_) => ProgressRepository());

final totalScoreProvider = FutureProvider<int>((ref) =>
    ref.read(progressRepositoryProvider).getTotalScore());

final categoryAccuracyProvider =
    FutureProvider.family<Map<String, double>, Map<String, String>>(
        (ref, questionToCategoryMap) => ref
            .read(progressRepositoryProvider)
            .getAccuracyByCategory(questionToCategoryMap));
