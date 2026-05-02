import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/scenario.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/scenario_list_screen.dart';
import '../ui/screens/scenario_detail_screen.dart';
import '../ui/screens/log_challenge_screen.dart';
import '../ui/screens/progress_screen.dart';

final routerProvider = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/scenarios',
      builder: (_, state) {
        final catName = state.uri.queryParameters['category'];
        ScenarioCategory? category;
        if (catName != null && catName.isNotEmpty) {
          try {
            category = ScenarioCategory.values.byName(catName);
          } catch (_) {
            category = null;
          }
        }
        return ScenarioListScreen(filterCategory: category);
      },
    ),
    GoRoute(
      path: '/scenario/:id',
      builder: (_, state) => ScenarioDetailScreen(
        scenarioId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/question/:id',
      builder: (_, state) => LogChallengeScreen(
        questionId: state.pathParameters['id']!,
        scenarioId: state.uri.queryParameters['scenarioId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/progress',
      builder: (_, __) => const ProgressScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('ページが見つかりません: ${state.uri}')),
  ),
);
