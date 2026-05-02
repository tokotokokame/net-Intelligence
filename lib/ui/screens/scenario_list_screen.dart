import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/scenario.dart';
import '../../providers/scenario_provider.dart';
import '../widgets/scenario_card.dart';

class ScenarioListScreen extends ConsumerWidget {
  final ScenarioCategory? filterCategory;
  const ScenarioListScreen({super.key, this.filterCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = filterCategory != null
        ? ref.watch(scenarioByCategoryProvider(filterCategory!))
        : ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('シナリオ一覧')),
      body: scenariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (scenarios) => scenarios.isEmpty
            ? const Center(child: Text('シナリオがありません'))
            : ListView.builder(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 8),
                itemCount: scenarios.length,
                itemBuilder: (ctx, i) => ScenarioCard(
                  scenario: scenarios[i],
                  onTap: () => context.push('/scenario/${scenarios[i].id}'),
                ),
              ),
      ),
    );
  }
}
