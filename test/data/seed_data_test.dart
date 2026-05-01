import 'package:flutter_test/flutter_test.dart';
import 'package:net_intelligence/data/seed_questions.dart';
import 'package:net_intelligence/data/seed_scenarios.dart';

void main() {
  group('シードデータ整合性テスト', () {
    test('全シナリオのquestionIdsが実在する問題を指している', () {
      final questionMap = {for (final q in kSeedQuestions) q.id: q};
      for (final scenario in kSeedScenarios) {
        for (final qId in scenario.questionIds) {
          expect(
            questionMap.containsKey(qId),
            isTrue,
            reason: 'シナリオ ${scenario.id} の questionId $qId が存在しない',
          );
        }
      }
    });

    test('全問題のscenarioIdが実在するシナリオを指している', () {
      final scenarioIds = {for (final s in kSeedScenarios) s.id};
      for (final question in kSeedQuestions) {
        expect(
          scenarioIds.contains(question.scenarioId),
          isTrue,
          reason: '問題 ${question.id} の scenarioId ${question.scenarioId} が存在しない',
        );
      }
    });

    test('シナリオが22件以上存在する（実サイバー攻撃事例を含む）', () {
      final realScenarios =
          kSeedScenarios.where((s) => s.id.startsWith('s_real_')).toList();
      expect(realScenarios.length, greaterThanOrEqualTo(22));
    });

    test('全問題に正解が1つ以上存在する', () {
      for (final question in kSeedQuestions) {
        final correctChoices =
            question.choices.where((c) => c.isCorrect).toList();
        expect(
          correctChoices.length,
          greaterThanOrEqualTo(1),
          reason: '問題 ${question.id} に正解がない',
        );
      }
    });

    test('全問題のexplanation.whatHappenedが空でない', () {
      for (final question in kSeedQuestions) {
        expect(
          question.explanation.whatHappened.isNotEmpty,
          isTrue,
          reason: '問題 ${question.id} のexplanationが空',
        );
        expect(
          question.explanation.nextActions.isNotEmpty,
          isTrue,
          reason: '問題 ${question.id} のnextActionsが空',
        );
      }
    });
  });
}
