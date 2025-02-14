import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/pages/details.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PokemonListTile extends ConsumerWidget {
  const PokemonListTile({
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
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Card(
          color: Colors.red.shade100,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error loading Pokemon',
              style: TextStyle(color: Colors.red.shade900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      loading: () => _buildTile(context, null, favPokemons, favoritesNotifier,
          loading: true),
    );
  }

Widget _buildTile(BuildContext context, Pokemon? pokemon,
    List<String> favPokemons, Favorites favoritesNotifier,
    {bool loading = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Skeletonizer(
      enabled: loading,
      child: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () {
            if (pokemon != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetails(
                    weight: pokemon.weight ?? 0, // Provide default value
                    abilities: pokemon.abilities?.toList() ?? [], // Default to empty list
                    species: pokemon.species?.name ?? 'Unknown', // Default to "Unknown"
                    image2: pokemon.sprites?.backShiny ?? '', // Default to empty string
                    ability: pokemon.species ?? Ability(name: 'Unknown'), // Default to placeholder
                    stats: pokemon.stats?.toList() ?? [], // Default to empty list
                    id: pokemon.id ?? 0, // Default to 0
                    height: pokemon.height ?? 0, // Default to 0
                    moves: (pokemon.moves?.length ?? 0).toString(), // Default to "0"
                    pokemonUrlDetails: pokemonUrl,
                    image1: pokemon.sprites?.frontShiny ?? '', // Default to empty string
                    name: name, // Default to "Unknown"
                  ),
                ),
              );
            }
          },
          child: SizedBox(
            width: double.infinity,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.shade900,
                    Colors.blue.shade900,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Row(
                  children: [
                    // Pokemon Image
                    Container(
                      width: 70,
                      height: 80,
                      color: Colors.white10,
                      child: Hero(
                        tag: pokemonUrl,
                        child: pokemon != null && pokemon.sprites != null
                            ? Image.network(
                                pokemon.sprites!.frontDefault ?? '', // Default to empty string
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.broken_image,
                                  color: Colors.white24,
                                ),
                              )
                            : const Icon(
                                Icons.catching_pokemon,
                                size: 30,
                                color: Colors.white24,
                              ),
                      ),
                    ),
                    // Pokemon Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              pokemon?.name?.toUpperCase() ?? 'Loading...', // Handle null name
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.flash_on,
                                  size: 12,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    '${pokemon?.moves?.length ?? 0} Moves', // Handle null moves
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Favorite Button
                    SizedBox(
                      width: 36,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (favPokemons.contains(pokemonUrl)) {
                            favoritesNotifier.removeFavorite(pokemonUrl);
                          } else {
                            favoritesNotifier.addFavorite(pokemonUrl);
                          }
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: Icon(
                            favPokemons.contains(pokemonUrl)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(favPokemons.contains(pokemonUrl)),
                            color: favPokemons.contains(pokemonUrl)
                                ? Colors.red
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}}

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
