import 'package:dress/index.dart';
import 'package:dress/outfit_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum AppRoute { preference, outfitAgent }

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: AppRoute.preference.name,
      builder: (context, state) => const PreferenceScreen(),
    ),
    GoRoute(
      path: '/outfit-agent',
      name: AppRoute.outfitAgent.name,
      builder: (context, state) => const OutfitAgentScreen(),
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: OutfitApp()));
}

class OutfitApp extends StatelessWidget {
  const OutfitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: _router,
    );
  }
}
