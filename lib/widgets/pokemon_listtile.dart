import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/pages/details.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PokemonListTile extends ConsumerWidget {
  PokemonListTile({
    super.key,
    required this.pokemonUrl,
    required this.name,
  });
  final String pokemonUrl;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesNotifier = ref.watch(favorites.notifier);
    final favPokemons = ref.watch(favorites);
    final pokemon = ref.watch(pokemonData(pokemonUrl));

    return pokemon.when(
      data: (data) => _buildTile(context, data, favPokemons, favoritesNotifier),
      error: (error, stackTrace) => Center(
          child: Text('Error: $error', style: TextStyle(color: Colors.red))),
      loading: () => _buildTile(context, null, favPokemons, favoritesNotifier,
          loading: true),
    );
  }

  Widget _buildTile(BuildContext context, Pokemon? pokemon,
      List<String> favPokemons, Favorites favoritesNotifier,
      {bool loading = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Skeletonizer(
        enabled: loading,
        child: FadeInUp(
          duration: Duration(milliseconds: 300),
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.blueGrey.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                trailing: IconButton(
                  onPressed: () {
                    if (favPokemons.contains(pokemonUrl)) {
                      favoritesNotifier.removeFavorite(pokemonUrl);
                    } else {
                      favoritesNotifier.addFavorite(pokemonUrl);
                    }
                  },
                  icon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      favPokemons.contains(pokemonUrl)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      key: ValueKey(favPokemons.contains(pokemonUrl)),
                      color: favPokemons.contains(pokemonUrl)
                          ? Colors.red
                          : Colors.white,
                    ),
                  ),
                ),
                leading: pokemon != null
                    ? Hero(
                        tag: pokemonUrl,
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(pokemon.sprites!.frontDefault!),
                          radius: 35,
                        ),
                      )
                    : CircleAvatar(
                        radius: 35, backgroundColor: Colors.grey[700]),
                onTap: () {
                  if (pokemon != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetails(
                          weight: pokemon.weight!,
                          abilities: pokemon.abilities!.toList(),
                          species: pokemon.species!.name.toString(),
                          image2: pokemon.sprites!.backShiny,
                          ability: pokemon.species!,
                          stats: pokemon.stats!.toList(),
                          id: pokemon.id,
                          height: pokemon.height!,
                          moves: pokemon.moves!.length.toString(),
                          pokemonUrlDetails: pokemonUrl,
                          image1: pokemon.sprites!.frontShiny,
                          name: name,
                        ),
                      ),
                    );
                  }
                },
                title: Text(
                  pokemon != null ? pokemon.name!.toUpperCase() : 'Loading...',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white),
                ),
                subtitle: Text(
                  '${pokemon?.moves?.length.toString() ?? 0} Moves',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
// class PokemonListtile extends ConsumerWidget {
//   PokemonListtile({
//     super.key,
//     required this.pokemonUrl,
//     required this.name,
//   });
//   final String pokemonUrl;
//   final String name;
//   late Favorites _favorites;
//   late List<String> _favpokemons;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     _favorites = ref.watch(favorites.notifier);
//     _favpokemons = ref.watch(favorites);
//     final pokemon = ref.watch(pokemonData(pokemonUrl));
//     return pokemon.when(
//       data: (data) {
//         return _tile(context, false, data);
//       },
//       error: (error, stackTrace) {
//         return Center(child: Text('Error: $error', style: TextStyle(color: Colors.red)));
//       },
//       loading: () {
//         return _tile(context, true, null);
//       },
//     );
//   }

//   Widget _tile(BuildContext context, bool loading, Pokemon? pokemon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Skeletonizer(
//         enabled: loading,
//         child: Card(
//           color: Colors.blueGrey[800],
//           elevation: 4,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           child: ListTile(
//             contentPadding: const EdgeInsets.all(12),
//             trailing: IconButton(
//               onPressed: () {
//                 if (_favpokemons.contains(pokemonUrl)) {
//                   _favorites.removeFavorite(pokemonUrl);
//                 } else {
//                   _favorites.addFavorite(pokemonUrl);
//                 }
//               },
//               icon: AnimatedSwitcher(
//                 duration: Duration(milliseconds: 300),
//                 transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
//                 child: Icon(
//                   _favpokemons.contains(pokemonUrl) ? Icons.favorite : Icons.favorite_border,
//                   key: ValueKey(_favpokemons.contains(pokemonUrl)),
//                   color: _favpokemons.contains(pokemonUrl) ? Colors.red : Colors.white,
//                 ),
//               ),
//             ),
//             leading: pokemon != null
//                 ? Hero(
//                     tag: pokemonUrl,
//                     child: CircleAvatar(
//                       backgroundImage: NetworkImage(pokemon.sprites!.frontDefault!),
//                       radius: 30,
//                     ),
//                   )
//                 : CircleAvatar(radius: 30, backgroundColor: Colors.grey[700]),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PokemonDetailss(
//                     ability: pokemon!.species!,
//                     stats: pokemon.stats!.toList(),
//                     id: pokemon.id,
//                     height: pokemon.height!,
//                     moves: pokemon.moves!.length.toString(),
//                     pokemonUrlDetails: pokemonUrl,
//                     image: pokemon.sprites!.frontShiny,
//                     name: name,
//                   ),
//                 ),
//               );
//             },
//             title: Text(
//               pokemon != null ? pokemon.name!.toUpperCase() : 'Loading...',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
//             ),
//             subtitle: Text(
//               '${pokemon?.moves?.length.toString() ?? 0} Moves',
//               style: TextStyle(fontSize: 14, color: Colors.white70),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
