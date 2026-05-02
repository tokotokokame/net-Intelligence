import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/scenario.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _categories = [
    (label: 'すべて',       icon: Icons.list_alt,  category: null),
    (label: 'L1-L2 障害',  icon: Icons.cable,      category: ScenarioCategory.layer1layer2),
    (label: 'L3 障害',     icon: Icons.router,     category: ScenarioCategory.layer3),
    (label: 'セキュリティ', icon: Icons.security,   category: ScenarioCategory.security),
    (label: 'キャパシティ', icon: Icons.speed,      category: ScenarioCategory.capacity),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Net.Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '習熟度',
            onPressed: () => context.push('/progress'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'カテゴリを選択',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  16, 0, 16,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  return _CategoryCard(
                    label: cat.label,
                    icon: cat.icon,
                    onTap: () => cat.category == null
                        ? context.push('/scenarios')
                        : context.push(
                            '/scenarios?category=\${cat.category!.name}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
