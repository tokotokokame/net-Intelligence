class QuestionResult {
  final String questionId;
  final String chosenChoiceId;
  final bool isCorrect;
  final int score;
  final DateTime answeredAt;

  const QuestionResult({
    required this.questionId,
    required this.chosenChoiceId,
    required this.isCorrect,
    required this.score,
    required this.answeredAt,
  });
}

class ScenarioProgress {
  final String scenarioId;
  final List<QuestionResult> results;
  final int totalScore;
  final bool isCompleted;

  const ScenarioProgress({
    required this.scenarioId,
    required this.results,
    required this.totalScore,
    required this.isCompleted,
  });

  double get accuracy =>
      results.isEmpty ? 0 : results.where((r) => r.isCorrect).length / results.length;
}
