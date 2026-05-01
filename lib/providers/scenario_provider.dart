import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scenario.dart';
import '../repositories/scenario_repository.dart';

final scenarioRepositoryProvider = Provider((_) => ScenarioRepository());

final scenarioListProvider = FutureProvider<List<Scenario>>((ref) {
  return ref.read(scenarioRepositoryProvider).getAll();
});

final scenarioByCategoryProvider =
    FutureProvider.family<List<Scenario>, ScenarioCategory>((ref, category) {
  return ref.read(scenarioRepositoryProvider).getByCategory(category);
});
