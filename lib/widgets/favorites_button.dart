import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/providers/pokemon_provider.dart';

class PokemonFavoriteButton extends ConsumerWidget {
  final String pokemonUrl;

  const PokemonFavoriteButton({super.key, required this.pokemonUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesNotifier = ref.watch(favorites.notifier);
    final favoritesList = ref.watch(favorites);
    final isFavorite = favoritesList.contains(pokemonUrl);

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.red,
      ),
      onPressed: () {
        if (isFavorite) {
          favoritesNotifier.removeFavorite(pokemonUrl);
        } else {
          favoritesNotifier.addFavorite(pokemonUrl);
        }
      },
    );
  }
}