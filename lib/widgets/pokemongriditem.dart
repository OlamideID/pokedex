import 'package:flutter/material.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/widgets/pokemon_listtile.dart';

class PokemonGridItem extends StatelessWidget {
  final PokemonListResult pokemon;
  final VoidCallback onTap;
  final TextEditingController searchController;
  final int index;

  const PokemonGridItem({
    super.key,
    required this.pokemon,
    required this.onTap,
    required this.searchController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return PokemonListTile(
      onTap: onTap,
      controller: searchController,
      pokemonUrl: pokemon.url!,
      name: pokemon.name!,
      index: index,
    );
  }
}
