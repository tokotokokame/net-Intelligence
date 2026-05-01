import 'package:flutter_test/flutter_test.dart';
import 'package:net_intelligence/models/question.dart';
import 'package:net_intelligence/models/choice.dart';
import 'package:net_intelligence/models/explanation.dart';
import 'package:net_intelligence/models/user_progress.dart';

void main() {
  group('Choice', () {
    test('正解の選択肢はscoreImpactが正', () {
      const choice = Choice(
        id: 'c1', text: '正解', isCorrect: true,
        scoreImpact: 100, feedbackText: '正解です',
      );
      expect(choice.isCorrect, isTrue);
      expect(choice.scoreImpact, greaterThan(0));
    });
  });

  group('Question', () {
    test('correctChoiceが正しく返る', () {
      const q = Question(
        id: 'q1', type: QuestionType.logChallenge,
        scenarioId: 's1', prompt: 'テスト問題',
        logLines: ['Apr 29 Router-A %OSPF: neighbor down'],
        choices: [
          Choice(id: 'a', text: '誤答', isCorrect: false, scoreImpact: 0, feedbackText: ''),
          Choice(id: 'b', text: '正解', isCorrect: true, scoreImpact: 100, feedbackText: ''),
        ],
        explanation: Explanation(
          whatHappened: 'OSPFネイバーがダウンした',
          nextActions: ['show ip ospf neighbor'],
        ),
      );
      expect(q.correctChoice?.id, equals('b'));
    });
  });

  group('ScenarioProgress', () {
    test('accuracyが正しく計算される', () {
      final now = DateTime.now();
      final progress = ScenarioProgress(
        scenarioId: 's1',
        results: [
          QuestionResult(questionId: 'q1', chosenChoiceId: 'b', isCorrect: true, score: 100, answeredAt: now),
          QuestionResult(questionId: 'q2', chosenChoiceId: 'a', isCorrect: false, score: 0, answeredAt: now),
        ],
        totalScore: 100,
        isCompleted: false,
      );
      expect(progress.accuracy, equals(0.5));
    });

    test('resultsが空のときaccuracyは0', () {
      const progress = ScenarioProgress(
        scenarioId: 's1',
        results: [],
        totalScore: 0,
        isCompleted: false,
      );
      expect(progress.accuracy, equals(0));
    });
  });
}
