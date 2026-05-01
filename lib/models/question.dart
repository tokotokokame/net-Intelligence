import 'choice.dart';
import 'explanation.dart';

enum QuestionType {
  logChallenge,
  decisionFlow,
}

class Question {
  final String id;
  final QuestionType type;
  final String scenarioId;
  final String prompt;
  final List<String> logLines;
  final List<Choice> choices;
  final Explanation explanation;
  final String? nextQuestionId;

  const Question({
    required this.id,
    required this.type,
    required this.scenarioId,
    required this.prompt,
    required this.logLines,
    required this.choices,
    required this.explanation,
    this.nextQuestionId,
  });

  Choice? get correctChoice =>
      choices.where((c) => c.isCorrect).firstOrNull;
}
