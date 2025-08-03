import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/widgets/favorites_button.dart';

class FavoriteCard extends StatelessWidget {
  final String url;
  final HomePageData homePageData;

  const FavoriteCard({
    super.key,
    required this.url,
    required this.homePageData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: PokeCard(
        pokemonUrl: url,
        name: _getPokemonName(url),
      ),
    );
  }

  String _getPokemonName(String url) {
    final pokemon = homePageData.data?.results?.firstWhere(
      (p) => p.url == url,
      orElse: () => PokemonListResult(name: 'Unknown', url: ''),
    );
    return pokemon?.name ?? 'Unknown';
  }
}

class PokeCard extends ConsumerWidget {
  const PokeCard({super.key, required this.pokemonUrl, required this.name});
  final String pokemonUrl;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(pokemonData(pokemonUrl));
    return pokemon.when(
      data: (data) =>
          data != null ? _buildCard(context, data) : _buildLoadingCard(),
      error: (error, stackTrace) =>
          const Center(child: Text('Error loading Pokémon')),
      loading: () => _buildLoadingCard(),
    );
  }

  Widget _buildCard(BuildContext context, Pokemon pokemon) {
    return InkWell(
      onTap: () {
        if (pokemon.stats == null || pokemon.species == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to load Pokémon details')),
          );
          return;
        }

        context.goNamed(
          'pokemon-details',
          pathParameters: {'name': pokemon.name ?? 'unknown'},
          extra: {
            'id': pokemon.id,
            'name': pokemon.name,
            'height': pokemon.height,
            'weight': pokemon.weight,
            'abilities': pokemon.abilities,
            'ability': pokemon.abilities?.first.ability,
            'image1': pokemon.sprites?.frontShiny ?? '',
            'image2': pokemon.sprites?.backShiny ?? '',
            'stats': pokemon.stats,
            'moves': pokemon.moves?.length.toString() ?? '',
            'species': pokemon.species?.name ?? 'Unknown',
            'pokemonUrlDetails': pokemonUrl,
          },
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          child: Stack(
            children: [
              // Favorite Button at Top Right
              Positioned(
                top: 6,
                right: 4,
                child: PokemonFavoriteButton(pokemonUrl: pokemonUrl),
              ),
              // Main Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pokémon Image
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: pokemon.sprites?.frontDefault != null
                          ? Image.network(
                              pokemon.sprites!.frontDefault!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.image_not_supported,
                              size: 80, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    // Pokémon Name
                    Text(
                      pokemon.name![0].toUpperCase() +
                          pokemon.name!.substring(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Loading Card
  Widget _buildLoadingCard() {
    return const Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
