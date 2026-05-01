import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('習熟度マップ')),
      body: const Center(
        child: Text('習熟度グラフ（Phase6で実装予定）'),
      ),
    );
  }
}
