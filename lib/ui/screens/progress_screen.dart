import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/progress_provider.dart';
import '../../data/seed_questions.dart';
import '../../data/seed_scenarios.dart';
import '../../models/scenario.dart';
import 'dart:developer' as developer;

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  static Map<String, String> _buildQuestionCategoryMap() {
    final map = <String, String>{};
    for (final q in kSeedQuestions) {
      final scenario =
          kSeedScenarios.where((s) => s.id == q.scenarioId).firstOrNull;
      if (scenario != null) map[q.id] = scenario.category.name;
    }
    return map;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionCategoryMap = _buildQuestionCategoryMap();
    final accuracyAsync = ref.watch(categoryAccuracyProvider(questionCategoryMap));
    final totalScoreAsync = ref.watch(totalScoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('習熟度マップ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            totalScoreAsync.when(
              loading: () => const SizedBox(),
              error: (e, _) => const SizedBox(),
              data: (score) => _ScoreCard(totalScore: score),
            ),
            const SizedBox(height: 24),
            const Text('カテゴリ別習熟度',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            accuracyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) {
                developer.log('[ProgressScreen] Error: $e');
                return Center(child: Text('エラー: $e'));
              },
              data: (accuracy) {
                if (accuracy.isEmpty) return const _EmptyProgressView();
                return Column(children: [
                  _AccuracyBarChart(accuracy: accuracy),
                  const SizedBox(height: 16),
                  ...ScenarioCategory.values.map((cat) => _CategoryRow(
                    category: cat,
                    accuracy: accuracy[cat.name] ?? 0.0,
                  )),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int totalScore;
  const _ScoreCard({required this.totalScore});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        const Icon(Icons.star, color: Colors.amber, size: 40),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('累計スコア',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          Text('$totalScore pt',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold)),
        ]),
      ]),
    ),
  );
}

class _EmptyProgressView extends StatelessWidget {
  const _EmptyProgressView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(40),
      child: Column(children: [
        Icon(Icons.school_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('まだ問題を解いていません',
            style: TextStyle(color: Colors.grey)),
        SizedBox(height: 8),
        Text('シナリオ一覧からトレーニングを始めましょう',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    ),
  );
}

class _AccuracyBarChart extends StatelessWidget {
  final Map<String, double> accuracy;
  const _AccuracyBarChart({required this.accuracy});

  static const _categoryLabels = {
    'layer1layer2': 'L1-L2',
    'layer3': 'L3',
    'security': 'セキュリティ',
    'capacity': 'キャパシティ',
  };

  @override
  Widget build(BuildContext context) {
    final bars = ScenarioCategory.values.map((cat) {
      final acc = accuracy[cat.name] ?? 0.0;
      return BarChartGroupData(x: cat.index, barRods: [
        BarChartRodData(
          toY: acc * 100,
          width: 40,
          color: acc >= 0.8
              ? Colors.green
              : acc >= 0.5
                  ? Colors.orange
                  : Colors.red,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ]);
    }).toList();

    return SizedBox(
      height: 200,
      child: BarChart(BarChartData(
        maxY: 100,
        barGroups: bars,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                _categoryLabels[ScenarioCategory.values[v.toInt()].name] ?? '',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}%',
                style: const TextStyle(fontSize: 10),
              ),
              reservedSize: 36,
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      )),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final ScenarioCategory category;
  final double accuracy;
  const _CategoryRow({required this.category, required this.accuracy});

  static const _labels = {
    ScenarioCategory.layer1layer2: 'L1-L2 障害',
    ScenarioCategory.layer3: 'L3 障害',
    ScenarioCategory.security: 'セキュリティインシデント',
    ScenarioCategory.capacity: 'キャパシティ・パフォーマンス',
  };

  @override
  Widget build(BuildContext context) {
    final pct = (accuracy * 100).round();
    final color = accuracy >= 0.8
        ? Colors.green
        : accuracy >= 0.5
            ? Colors.orange
            : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_labels[category] ?? category.name,
                style: const TextStyle(fontSize: 14)),
            Text('$pct%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: accuracy,
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ]),
    );
  }
}
