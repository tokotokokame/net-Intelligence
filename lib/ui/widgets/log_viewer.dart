import 'package:flutter/material.dart';

class LogViewer extends StatelessWidget {
  final List<String> logLines;

  const LogViewer({super.key, required this.logLines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: logLines.map((line) => Text(
          line,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Color(0xFF00FF41),
            height: 1.6,
          ),
        )).toList(),
      ),
    );
  }
}
