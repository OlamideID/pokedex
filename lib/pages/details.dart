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
    Colors.red.shade400,
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.amber.shade400
  ];

  @override
  Widget build(BuildContext context) {
    final favorite = ref.watch(favorites.notifier);
    final favpokemons = ref.watch(favorites);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (favpokemons.contains(widget.pokemonUrlDetails)) {
                  favorite.removeFavorite(widget.pokemonUrlDetails);
                } else {
                  favorite.addFavorite(widget.pokemonUrlDetails);
                }
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  favpokemons.contains(widget.pokemonUrlDetails)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  key: ValueKey(favpokemons.contains(widget.pokemonUrlDetails)),
                  color: favpokemons.contains(widget.pokemonUrlDetails)
                      ? Colors.red
                      : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.indigo.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '#${widget.id?.toString().padLeft(3, '0') ?? "???"}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.name[0].toUpperCase() +
                          widget.name.substring(1).toLowerCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Hero(
                      tag: widget.heroTag ?? widget.name,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.image1 != null)
                            Expanded(
                              child: Image.network(
                                widget.image1!,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                            ),
                          if (widget.image2 != null) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: Image.network(
                                widget.image2!,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                          'Height',
                          '${widget.height / 10} m',
                          Icons.height,
                        ),
                        _buildInfoCard(
                          'Weight',
                          '${widget.weight / 10} kg',
                          Icons.monitor_weight_outlined,
                        ),
                        _buildInfoCard(
                          'Moves',
                          widget.moves,
                          Icons.flash_on,
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Stats',
                    _buildHorizontalStatsLines(),
                  ),
                  _buildSection(
                    'Abilities',
                    Column(
                      children: (widget.abilities ?? []).map((abil) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.auto_awesome),
                            title: Text(
                              abil.ability?.name ?? 'Unknown',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[700], size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStatsLines() {
    return Column(
      children: widget.stats.asMap().entries.map((entry) {
        int index = entry.key;
        Stats stat = entry.value;

        // Safe access to baseStat with default value
        final baseStat = stat.baseStat ?? 0;
        double widthFactor = baseStat / 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _capitalizeStatName(stat.stat?.name ?? 'Unknown'),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    baseStat.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  // Background bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Progress bar
                  FractionallySizedBox(
                    widthFactor: widthFactor.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: statColors[index % statColors.length],
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: statColors[index % statColors.length]
                                .withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _capitalizeStatName(String name) {
    if (name.isEmpty) return name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}
