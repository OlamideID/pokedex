import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/pages/details.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/widgets/favorites_button.dart';

class PokeCard extends ConsumerWidget {
  const PokeCard({super.key, required this.pokemonUrl, required this.name});
  final String pokemonUrl;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetails(
              weight: pokemon.weight ?? 0,
              height: pokemon.height ?? 0,
              species: pokemon.species?.name ?? 'Unknown',
              moves: (pokemon.moves?.length ?? 0).toString(),
              name: name,
              abilities: pokemon.abilities ?? [],
              image1: pokemon.sprites?.frontShiny ?? '',
              image2: pokemon.sprites?.backShiny ?? '',
              id: pokemon.id ?? 0,
              ability: (pokemon.abilities?.isNotEmpty ?? false)
                  ? pokemon.abilities!.first.ability!
                  : Ability(name: 'Unknown', url: ''),
              pokemonUrlDetails: pokemonUrl,
              stats: pokemon.stats ?? [],
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                      )
                    : const Icon(Icons.image_not_supported,
                        size: 60, color: Colors.grey),
              ),
              const SizedBox(height: 6),

              // Pokémon Name
              Text(
                pokemon.name?.toUpperCase() ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Pokémon ID
              Text(
                '#${pokemon.id ?? "N/A"}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              // Height & Weight with Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatIcon(
                      Icons.height, '${(pokemon.height ?? 0) / 10}m'),
                  const SizedBox(width: 6),
                  _buildStatIcon(
                      Icons.fitness_center, '${(pokemon.weight ?? 0) / 10}kg'),
                ],
              ),

              // Abilities (Stacked)
              if (pokemon.abilities?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Column(
                  children: pokemon.abilities!.map((ability) {
                    return Text(
                      ability.ability!.name!,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w500),
                    );
                  }).toList(),
                ),
              ],

              // Favorite Button
              const SizedBox(height: 4),
              PokemonFavoriteButton(pokemonUrl: pokemonUrl),
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

  // Small stat icon with text
  Widget _buildStatIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 2),
        Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
