import 'package:flutter/material.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/widgets/pokemon_listtile.dart';

class PokemonGridItem extends StatelessWidget {
  final PokemonListResult pokemon;
  final VoidCallback onTap;
  final TextEditingController searchController;

  const PokemonGridItem({
    super.key,
    required this.pokemon,
    required this.onTap,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
        child: PokemonListTile(
          onTap: onTap,
          controller: searchController,
          pokemonUrl: pokemon.url!,
          name: pokemon.name!,
        ),
      ),
    );
  }
}
