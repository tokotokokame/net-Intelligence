class Choice {
  final String id;
  final String text;
  final bool isCorrect;
  final int scoreImpact;
  final String feedbackText;

  const Choice({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.scoreImpact,
    required this.feedbackText,
  });
}
