import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/seed_questions.dart';
import '../../data/seed_scenarios.dart';

class ScenarioDetailScreen extends StatelessWidget {
  final String scenarioId;
  const ScenarioDetailScreen({super.key, required this.scenarioId});

  @override
  Widget build(BuildContext context) {
    final scenario = kSeedScenarios.where((s) => s.id == scenarioId).firstOrNull;
    if (scenario == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('シナリオ')),
        body: Center(child: Text('シナリオが見つかりません: $scenarioId')),
      );
    }

    final questions = kSeedQuestions.where((q) => q.scenarioId == scenarioId).toList();

    return Scaffold(
      appBar: AppBar(title: Text(scenario.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(scenario.description, style: const TextStyle(fontSize: 15)),
            if (scenario.prerequisite != null) ...[
              const SizedBox(height: 8),
              Text('前提知識: ${scenario.prerequisite}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            const SizedBox(height: 24),
            const Text('問題一覧', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (ctx, i) {
                  final q = questions[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(q.prompt, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(q.type.name),
                      onTap: () => context.push('/question/${q.id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
