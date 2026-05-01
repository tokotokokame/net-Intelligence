import 'package:flutter/material.dart';
import '../../models/explanation.dart';

class ExplanationPanel extends StatelessWidget {
  final Explanation explanation;
  final bool isCorrect;
  final String feedbackText;

  const ExplanationPanel({
    super.key,
    required this.explanation,
    required this.isCorrect,
    required this.feedbackText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(isCorrect ? '正解！' : '不正解',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                )),
          ]),
          const SizedBox(height: 8),
          Text(feedbackText, style: const TextStyle(color: Colors.white70)),
          const Divider(height: 24),
          const Text('解説', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(explanation.whatHappened),
          if (explanation.nextActions.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('次に確認すること', style: TextStyle(fontWeight: FontWeight.bold)),
            ...explanation.nextActions.map((a) => Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text('• $a', style: const TextStyle(fontSize: 13)),
            )),
          ],
          if (explanation.relatedCommands.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('関連コマンド', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: explanation.relatedCommands.map((c) => Text(
                  c,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF00FF41)),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
