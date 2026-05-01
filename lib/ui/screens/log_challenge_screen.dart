import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/question.dart';
import '../../models/choice.dart';
import '../../data/seed_questions.dart';
import '../widgets/log_viewer.dart';
import '../widgets/choice_button.dart';
import '../widgets/explanation_panel.dart';
import 'dart:developer' as developer;

class LogChallengeScreen extends ConsumerStatefulWidget {
  final String questionId;
  const LogChallengeScreen({super.key, required this.questionId});

  @override
  ConsumerState<LogChallengeScreen> createState() => _LogChallengeScreenState();
}

class _LogChallengeScreenState extends ConsumerState<LogChallengeScreen> {
  String? _selectedChoiceId;
  bool _answered = false;

  Question? get _question =>
      kSeedQuestions.where((q) => q.id == widget.questionId).firstOrNull;

  ChoiceState _stateFor(Choice choice) {
    if (!_answered) {
      return _selectedChoiceId == choice.id
          ? ChoiceState.selected
          : ChoiceState.idle;
    }
    if (choice.isCorrect) return ChoiceState.correct;
    if (_selectedChoiceId == choice.id) return ChoiceState.wrong;
    return ChoiceState.idle;
  }

  void _onChoiceTap(Choice choice) {
    if (_answered) return;
    setState(() => _selectedChoiceId = choice.id);
    developer.log('[LogChallenge] Selected: ${choice.id} (${choice.text})');
  }

  void _onAnswerCheck() {
    if (_selectedChoiceId == null) return;
    setState(() => _answered = true);
    final q = _question!;
    final selected = q.choices.firstWhere((c) => c.id == _selectedChoiceId);
    developer.log('[LogChallenge] Answered: correct=${selected.isCorrect}, score=${selected.scoreImpact}');
  }

  @override
  Widget build(BuildContext context) {
    final q = _question;
    if (q == null) {
      return Scaffold(body: Center(child: Text('問題が見つかりません: ${widget.questionId}')));
    }

    final selectedChoice = _answered && _selectedChoiceId != null
        ? q.choices.firstWhere((c) => c.id == _selectedChoiceId)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(q.type == QuestionType.logChallenge ? 'ログ解読チャレンジ' : '判断フローゲーム'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (q.logLines.isNotEmpty) ...[
              const Text('Syslog', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LogViewer(logLines: q.logLines),
              const SizedBox(height: 16),
            ],
            Text(q.prompt, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            ...q.choices.map((c) => ChoiceButton(
              choice: c,
              state: _stateFor(c),
              onTap: () => _onChoiceTap(c),
            )),
            const SizedBox(height: 16),
            if (!_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedChoiceId != null ? _onAnswerCheck : null,
                  child: const Text('答え合わせ'),
                ),
              ),
            if (_answered && selectedChoice != null) ...[
              const SizedBox(height: 16),
              ExplanationPanel(
                explanation: q.explanation,
                isCorrect: selectedChoice.isCorrect,
                feedbackText: selectedChoice.feedbackText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
