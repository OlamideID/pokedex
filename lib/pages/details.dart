import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/pokemon_provider.dart';

class PokemonDetails extends ConsumerStatefulWidget {
  final String? image1;
  final String? image2;
  final String species;
  final String name;
  final String? heroTag;
  final String? pokemonDetail;
  final String pokemonUrlDetails;
  final String moves;
  final int height;
  final int? id;
  final int weight;

  final List<Stats> stats;
  final Ability ability;
  final List<Abilities>? abilities;

  const PokemonDetails({
    required this.height,
    required this.weight,
    required this.species,
    required this.moves,
    required this.name,
    required this.abilities,
    super.key,
    this.image1,
    this.image2,
    this.id,
    required this.ability,
    required this.pokemonUrlDetails,
    this.heroTag,
    this.pokemonDetail,
    required this.stats,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PokemonDetailsState();
}

class _PokemonDetailsState extends ConsumerState<PokemonDetails> {
  final List<Color> statColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow
  ];

  @override
  Widget build(BuildContext context) {
    final favorite = ref.watch(favorites.notifier);
    final favpokemons = ref.watch(favorites);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          widget.name[0].toUpperCase() + widget.name.substring(1).toLowerCase(),
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (favpokemons.contains(widget.pokemonUrlDetails)) {
                favorite.removeFavorite(widget.pokemonUrlDetails);
              } else {
                favorite.addFavorite(widget.pokemonUrlDetails);
              }
            },
            icon: Icon(
              favpokemons.contains(widget.pokemonUrlDetails)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: favpokemons.contains(widget.pokemonUrlDetails)
                  ? Colors.red
                  : Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: widget.heroTag ?? widget.name,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.image1 != null)
                    Expanded(
                      child: Image.network(
                        widget.image1!,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (widget.image2 != null) ...[
                    const SizedBox(width: 10), // Reduce spacing
                    Expanded(
                      child: Image.network(
                        widget.image2!,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Basic Information",
                        style: TextStyle(
                          fontSize: 20,
                        )),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                        'Name',
                        widget.name[0].toUpperCase() +
                            widget.name.substring(1).toLowerCase()),
                    _buildInfoRow("Height", "${widget.height}"),
                    _buildInfoRow('Weight', widget.weight.toString()),
                    _buildInfoRow("Moves", widget.moves),
                    _buildInfoRow("ID", widget.id?.toString() ?? "N/A"),
                    _buildInfoRow(
                        'Species',
                        widget.species[0].toUpperCase() +
                            widget.species.substring(1).toLowerCase()),
                    _buildInfoRow("Ability", widget.ability.name.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Stats",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 10),
            _buildHorizontalStatsLines(),
            const SizedBox(height: 20),
            Text("Abilities",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: widget.abilities!
                  .map((abil) => Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            abil.ability!.name!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalStatsLines() {
    return Column(
      children: widget.stats.asMap().entries.map((entry) {
        int index = entry.key;
        Stats stat = entry.value;
        double widthFactor = stat.baseStat! / 100;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(stat.stat!.name!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Tooltip(
                  message: "${(widthFactor * 100).toStringAsFixed(1)}%",
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: widthFactor.clamp(0.0, 1.0),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: statColors[index % statColors.length],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(stat.baseStat.toString(),
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle()),
            ],
          ),
        ],
      ),
    );
  }
}
