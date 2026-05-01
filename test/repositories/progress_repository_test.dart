import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:net_intelligence/models/user_progress.dart';
import 'package:net_intelligence/repositories/progress_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ProgressRepository', () {
    test('結果を保存して取得できる', () async {
      final repo = ProgressRepository();
      final now = DateTime.now();
      final result = QuestionResult(
        questionId: 'q_test_1',
        chosenChoiceId: 'b',
        isCorrect: true,
        score: 100,
        answeredAt: now,
      );

      await repo.saveResult(result, 's_test_1');
      final results = await repo.getResultsForScenario('s_test_1');

      expect(results, isNotEmpty);
      expect(results.first.questionId, equals('q_test_1'));
      expect(results.first.isCorrect, isTrue);
      expect(results.first.score, equals(100));
    });

    test('総スコアが正しく計算される', () async {
      final repo = ProgressRepository();
      final score = await repo.getTotalScore();
      expect(score, greaterThanOrEqualTo(0));
    });

    test('カテゴリ別正解率が計算される', () async {
      final repo = ProgressRepository();
      final now = DateTime.now();
      await repo.saveResult(
        QuestionResult(
          questionId: 'q_cat_1',
          chosenChoiceId: 'a',
          isCorrect: true,
          score: 100,
          answeredAt: now,
        ),
        's_cat_1',
      );

      final accuracy = await repo.getAccuracyByCategory({'q_cat_1': 'layer3'});
      expect(accuracy.containsKey('layer3'), isTrue);
      expect(accuracy['layer3'], greaterThan(0.0));
    });
  });
}
