import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/scenario.dart';
import '../../models/question.dart';
import '../../data/seed_questions.dart';
import '../../data/seed_scenarios.dart';

class ScenarioDetailScreen extends ConsumerWidget {
  final String scenarioId;
  const ScenarioDetailScreen({super.key, required this.scenarioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenario = kSeedScenarios.where((s) => s.id == scenarioId).firstOrNull;

    if (scenario == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('シナリオ詳細')),
        body: Center(child: Text('シナリオが見つかりません: $scenarioId')),
      );
    }

    final questions = kSeedQuestions.where((q) => q.scenarioId == scenarioId).toList();

    return Scaffold(
      appBar: AppBar(title: Text(scenario.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _Badge(label: _categoryLabel(scenario.category), color: Colors.blue),
              const SizedBox(width: 8),
              _Badge(
                label: _difficultyLabel(scenario.difficulty),
                color: _difficultyColor(scenario.difficulty),
              ),
            ]),
            const SizedBox(height: 16),
            Text(scenario.description,
                style: const TextStyle(fontSize: 15, height: 1.7)),
            if (scenario.prerequisite != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.school, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('前提: ${scenario.prerequisite}',
                        style: const TextStyle(fontSize: 13)),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 24),
            Text('問題一覧（${questions.length}問）',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...questions.asMap().entries.map((e) => _QuestionTile(
              index: e.key + 1,
              question: e.value,
              onTap: () => context.push('/question/${e.value.id}?scenario=$scenarioId'),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('最初から始める'),
                onPressed: questions.isEmpty
                    ? null
                    : () => context.push(
                        '/question/${questions.first.id}?scenario=$scenarioId'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(ScenarioCategory c) => switch (c) {
    ScenarioCategory.layer1layer2 => 'L1-L2',
    ScenarioCategory.layer3       => 'L3',
    ScenarioCategory.security     => 'セキュリティ',
    ScenarioCategory.capacity     => 'キャパシティ',
  };

  String _difficultyLabel(DifficultyLevel d) => switch (d) {
    DifficultyLevel.beginner     => '初級',
    DifficultyLevel.intermediate => '中級',
    DifficultyLevel.advanced     => '上級',
  };

  Color _difficultyColor(DifficultyLevel d) => switch (d) {
    DifficultyLevel.beginner     => Colors.green,
    DifficultyLevel.intermediate => Colors.orange,
    DifficultyLevel.advanced     => Colors.red,
  };
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.5)),
    ),
    child: Text(label, style: TextStyle(fontSize: 12, color: color)),
  );
}

class _QuestionTile extends StatelessWidget {
  final int index;
  final Question question;
  final VoidCallback onTap;
  const _QuestionTile({
    required this.index,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text('$index', style: const TextStyle(fontSize: 13)),
    ),
    title: Text(question.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      question.type == QuestionType.logChallenge ? 'ログ解読' : '判断フロー',
      style: const TextStyle(fontSize: 12),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
