class Explanation {
  final String whatHappened;
  final List<String> nextActions;
  final List<String> relatedCommands;
  final String? studyReference;

  const Explanation({
    required this.whatHappened,
    required this.nextActions,
    this.relatedCommands = const [],
    this.studyReference,
  });
}
