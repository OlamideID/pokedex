import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PokemonListtile extends ConsumerWidget {
  PokemonListtile({super.key, required this.pokemonUrl});
  final String pokemonUrl;
  late Favorites _favorites;
  late List<String> _favpokemons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _favorites = ref.watch(favorites.notifier);
    _favpokemons = ref.watch(favorites);
    final pokemon = ref.watch(pokemonData(pokemonUrl));
    return pokemon.when(
      data: (data) {
        return _tile(context, false, data);
      },
      error: (error, stackTrace) {
        return Text('Error $error');
      },
      loading: () {
        return _tile(context, true, null);
      },
    );
  }

  Widget _tile(BuildContext context, bool loading, Pokemon? pokemon) {
    return Skeletonizer(
      enabled: loading,
      child: ListTile(
        trailing: IconButton(
          onPressed: () {
            if (_favpokemons.contains(pokemonUrl)) {
              _favorites.removeFavorite(pokemonUrl);
            } else {
              _favorites.addFavorite(pokemonUrl);
            }
          },
          icon: Icon(_favpokemons.contains(pokemonUrl)
              ? Icons.favorite
              : Icons.favorite_border),
          color: _favpokemons.contains(pokemonUrl) ? Colors.red : null,
        ),
        leading: pokemon != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(pokemon.sprites!.frontDefault!),
              )
            : CircleAvatar(),
        onTap: () {
          print('tapped');
        },
        title: Text(pokemon != null ? pokemon.name!.toUpperCase() : 'Wahala'),
        subtitle: Text('${pokemon?.moves?.length.toString() ?? 0} Moves '),
      ),
    );
  }
}
