import 'package:flutter/material.dart';
import '../../models/scenario.dart';

class ScenarioCard extends StatelessWidget {
  final Scenario scenario;
  final VoidCallback onTap;

  const ScenarioCard({
    super.key,
    required this.scenario,
    required this.onTap,
  });

  Color _difficultyColor() => switch (scenario.difficulty) {
    DifficultyLevel.beginner     => Colors.green,
    DifficultyLevel.intermediate => Colors.orange,
    DifficultyLevel.advanced     => Colors.red,
  };

  String _difficultyLabel() => switch (scenario.difficulty) {
    DifficultyLevel.beginner     => '初級',
    DifficultyLevel.intermediate => '中級',
    DifficultyLevel.advanced     => '上級',
  };

  String _categoryLabel() => switch (scenario.category) {
    ScenarioCategory.layer1layer2 => 'L1-L2',
    ScenarioCategory.layer3       => 'L3',
    ScenarioCategory.security     => 'セキュリティ',
    ScenarioCategory.capacity     => 'キャパシティ',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(scenario.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(scenario.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        leading: CircleAvatar(
          backgroundColor: _difficultyColor().withValues(alpha: 0.2),
          child: Text(_categoryLabel(),
              style: TextStyle(fontSize: 11, color: _difficultyColor())),
        ),
        trailing: Chip(
          label: Text(_difficultyLabel(), style: const TextStyle(fontSize: 11)),
          backgroundColor: _difficultyColor().withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
