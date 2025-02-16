import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/pages/details.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/providers/searchprov.dart';

class PokemonListTile extends ConsumerStatefulWidget {
  const PokemonListTile({
    super.key,
    required this.pokemonUrl,
    required this.name,
    required this.controller,
    this.onTap,
  });

  final String pokemonUrl;
  final String name;
  final TextEditingController controller;
  final VoidCallback? onTap;

  @override
  ConsumerState<PokemonListTile> createState() => _PokemonListTileState();
}

class _PokemonListTileState extends ConsumerState<PokemonListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  // Use select to minimize rebuilds
  final isFavorite = ref.watch(
      favorites.select((favorites) => favorites.contains(widget.pokemonUrl)));

  return RepaintBoundary(
    child: LayoutBuilder(
      builder: (context, constraints) {
        return ref.watch(pokemonData(widget.pokemonUrl)).when(
              data: (pokemon) {
                // Add a null check for the pokemon object
                if (pokemon == null) {
                  return _buildErrorTile(); // Handle null pokemon
                }
                return _buildTile(pokemon, isFavorite);
              },
              error: (_, __) => _buildErrorTile(),
              loading: () => _buildLoadingTile(),
            );
      },
    ),
  );
}

Widget _buildTile(Pokemon pokemon, bool isFavorite) {
  // Ensure pokemon is not null
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => _navigateToDetails(pokemon),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildImageSection(pokemon),
            ),
            Expanded(
              flex: 2,
              child: _buildInfoSection(pokemon, isFavorite),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildImageSection(Pokemon pokemon) {
  // Ensure pokemon.sprites is not null
  final imageUrl = pokemon.sprites?.frontDefault;

  return Hero(
    tag: widget.pokemonUrl,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Center(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                height: 100,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.white24,
                ),
              )
            : const Icon(
                Icons.catching_pokemon,
                size: 40,
                color: Colors.white24,
              ),
      ),
    ),
  );
}

 Widget _buildInfoSection(Pokemon pokemon, bool isFavorite) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Constrain the text width to avoid overlapping with the favorites button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4, // Adjust the width as needed
              child: Text(
                pokemon.name?.toUpperCase() ?? 'Unknown Pokémon',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.flash_on, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${pokemon.moves?.length ?? 0} Moves',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 10,
          right: -10,
          child: IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildLoadingTile() {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white24,
                              Colors.white,
                              Colors.white24,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment(
                                -1.0 + _shimmerController.value * 2, 0.0),
                            end: Alignment(
                                1.0 + _shimmerController.value * 2, 0.0),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white24,
                                Colors.white,
                                Colors.white24,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment(
                                  -1.0 + _shimmerController.value * 2, 0.0),
                              end: Alignment(
                                  1.0 + _shimmerController.value * 2, 0.0),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white24,
                                Colors.white,
                                Colors.white24,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment(
                                  -1.0 + _shimmerController.value * 2, 0.0),
                              end: Alignment(
                                  1.0 + _shimmerController.value * 2, 0.0),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: const Center(
        child: Text(
          'Error loading Pokémon',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    final favoritesNotifier = ref.read(favorites.notifier);
    if (ref.read(favorites).contains(widget.pokemonUrl)) {
      favoritesNotifier.removeFavorite(widget.pokemonUrl);
    } else {
      favoritesNotifier.addFavorite(widget.pokemonUrl);
    }
  }

  void _navigateToDetails(Pokemon pokemon) {
    widget.onTap?.call();
    ref.read(pokemonSearchProvider.notifier).clearSearch();
    widget.controller.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetails(
          weight: pokemon.weight ?? 0,
          abilities: pokemon.abilities?.toList() ?? [],
          species: pokemon.species?.name ?? 'Unknown',
          image2: pokemon.sprites?.backShiny ?? '',
          ability: pokemon.species ?? Ability(name: 'Unknown'),
          stats: pokemon.stats?.toList() ?? [],
          id: pokemon.id ?? 0,
          height: pokemon.height ?? 0,
          moves: (pokemon.moves?.length ?? 0).toString(),
          pokemonUrlDetails: widget.pokemonUrl,
          image1: pokemon.sprites?.frontShiny ?? '',
          name: widget.name,
        ),
      ),
    );
  }
}
