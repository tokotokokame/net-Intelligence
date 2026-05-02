import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/scenario.dart';
import '../../providers/scenario_provider.dart';
import '../widgets/scenario_card.dart';
import 'dart:developer' as developer;

class ScenarioListScreen extends ConsumerWidget {
  final ScenarioCategory? filterCategory;
  const ScenarioListScreen({super.key, this.filterCategory});

  String get _categoryLabel => filterCategory == null ? 'すべて' : switch (filterCategory!) {
    ScenarioCategory.layer1layer2 => 'L1-L2 障害',
    ScenarioCategory.layer3       => 'L3 障害',
    ScenarioCategory.security     => 'セキュリティ',
    ScenarioCategory.capacity     => 'キャパシティ',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('[ScenarioListScreen] filterCategory: $filterCategory');

    final scenariosAsync = filterCategory != null
        ? ref.watch(scenarioByCategoryProvider(filterCategory!))
        : ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('シナリオ一覧: $_categoryLabel')),
      body: scenariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          developer.log('[ScenarioListScreen] Error: $e');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('読み込みエラー: $e', textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(scenarioListProvider),
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (scenarios) {
          developer.log('[ScenarioListScreen] Loaded \${scenarios.length} scenarios');
          if (scenarios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('「$_categoryLabel」のシナリオがありません',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/scenarios'),
                      child: const Text('すべて表示'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            itemCount: scenarios.length,
            itemBuilder: (ctx, i) => ScenarioCard(
              scenario: scenarios[i],
              onTap: () => context.push('/scenario/\${scenarios[i].id}'),
            ),
          );
        },
      ),
    );
  }
}
