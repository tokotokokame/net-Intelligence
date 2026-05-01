import 'package:go_router/go_router.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/scenario_list_screen.dart';
import '../ui/screens/scenario_detail_screen.dart';
import '../ui/screens/log_challenge_screen.dart';
import '../ui/screens/progress_screen.dart';
import '../models/scenario.dart';

final routerProvider = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/scenarios',
      builder: (_, state) {
        final catName = state.uri.queryParameters['category'];
        final category = catName != null
            ? ScenarioCategory.values.byName(catName)
            : null;
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
        scenarioId: state.uri.queryParameters['scenario'] ?? '',
      ),
    ),
    GoRoute(
      path: '/progress',
      builder: (_, __) => const ProgressScreen(),
    ),
  ],
);
