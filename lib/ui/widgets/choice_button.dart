import 'package:flutter/material.dart';
import '../../models/choice.dart';

enum ChoiceState { idle, selected, correct, wrong }

class ChoiceButton extends StatelessWidget {
  final Choice choice;
  final ChoiceState state;
  final VoidCallback? onTap;

  const ChoiceButton({
    super.key,
    required this.choice,
    required this.state,
    this.onTap,
  });

  Color _bgColor() => switch (state) {
    ChoiceState.idle     => Colors.transparent,
    ChoiceState.selected => Colors.blue.withValues(alpha: 0.2),
    ChoiceState.correct  => Colors.green.withValues(alpha: 0.25),
    ChoiceState.wrong    => Colors.red.withValues(alpha: 0.2),
  };

  Color _borderColor() => switch (state) {
    ChoiceState.idle     => Colors.grey.withValues(alpha: 0.4),
    ChoiceState.selected => Colors.blue,
    ChoiceState.correct  => Colors.green,
    ChoiceState.wrong    => Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state == ChoiceState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgColor(),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor()),
        ),
        child: Row(
          children: [
            Expanded(child: Text(choice.text)),
            if (state == ChoiceState.correct) const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (state == ChoiceState.wrong)   const Icon(Icons.cancel,       color: Colors.red,   size: 20),
          ],
        ),
      ),
    );
  }
}
