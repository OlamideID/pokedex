import 'package:go_router/go_router.dart';
import 'package:poke/pages/details.dart';
import 'package:poke/pages/home.dart';
import 'package:poke/pages/splash.dart';

final router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: ':name',
          name: 'pokemon-details',
          builder: (context, state) {
            final name = state.pathParameters['name'] ?? 'unknown';
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return PokemonDetails(
              id: extra['id'] ?? 0,
              name: name,
              height: extra['height'] ?? 0,
              weight: extra['weight'] ?? 0,
              abilities: extra['abilities'] ?? [],
              ability: extra['ability'],
              image1: extra['image1'] ?? '',
              image2: extra['image2'] ?? '',
              stats: extra['stats'] ?? [],
              moves: extra['moves'] ?? '',
              species: extra['species'] ?? 'Unknown',
              pokemonUrlDetails: extra['pokemonUrlDetails'] ?? '',
            );
          },
        ),
      ],
    ),
  ],
);
