import 'package:go_router/go_router.dart';

import 'features/dashboard/dashboard_screen.dart';
import 'features/reminder/reminder_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/transactions/transaction_form_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
    GoRoute(
      path: '/transaction/new', 
      builder: (context, state) {
        final direction = state.uri.queryParameters['direction'];
        return TransactionFormScreen(initialDirection: direction);
      },
    ),
    GoRoute(
      path: '/transaction/:id/edit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TransactionFormScreen(transactionId: id);
      },
    ),
    GoRoute(
      path: '/transaction/:id/reminder',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ReminderScreen(transactionId: id);
      },
    ),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
