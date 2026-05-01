enum ScenarioCategory {
  layer1layer2,
  layer3,
  security,
  capacity,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

class Scenario {
  final String id;
  final String title;
  final String description;
  final ScenarioCategory category;
  final DifficultyLevel difficulty;
  final List<String> questionIds;
  final String? prerequisite;

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.questionIds,
    this.prerequisite,
  });
}
