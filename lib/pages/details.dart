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
  final List stats;
  final Ability ability;
  final List? abilities;

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
  ConsumerState createState() => _PokemonDetailsState();
}

class _PokemonDetailsState extends ConsumerState<PokemonDetails>
    with SingleTickerProviderStateMixin {
  bool _showDetails = false;
  late AnimationController _controller;
  final Color primaryColor = const Color(0xFF6C5CE7); // Deep purple
  final Color secondaryColor = const Color(0xFFA8A4FF); // Light purple
  final Color accentColor = const Color(0xFFFF9FF3); // Soft pink
  final Color backgroundColor = const Color(0xFF2D3436); // Dark slate

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _showDetails = true);
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorite = ref.watch(favorites.notifier);
    final favpokemons = ref.watch(favorites);
    final height = MediaQuery.of(context).size.height;
    print(widget.pokemonUrlDetails);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _controller.forward(from: 0.0);
              if (favpokemons.contains(widget.pokemonUrlDetails)) {
                favorite.removeFavorite(widget.pokemonUrlDetails);
              } else {
                favorite.addFavorite(widget.pokemonUrlDetails);
              }
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Transform.rotate(
                    // scale: _controller.value * 1,
                    angle: _controller.value * 2 * 3.1416,
                    child: Icon(
                      favpokemons.contains(widget.pokemonUrlDetails)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: accentColor,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              // Pokemon ID and Name Header
              if (widget.name.length <= 10)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: secondaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${widget.id?.toString().padLeft(3, '0') ?? "???"}',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.name[0].toUpperCase() +
                                widget.name.substring(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: secondaryColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.species[0].toUpperCase() +
                              widget.species.substring(1),
                          style: TextStyle(
                            color: secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: secondaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${widget.id?.toString().padLeft(3, '0') ?? "???"}',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.name[0].toUpperCase() +
                                    widget.name.substring(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: secondaryColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.species[0].toUpperCase() +
                                  widget.species.substring(1),
                              style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Image Comparison Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  height: height * 0.25,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: secondaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Hero(
                            tag: '${widget.heroTag ?? widget.name}_1',
                            child: Image.network(
                              widget.image1 ?? '',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Image.network(
                            widget.image2 ?? '',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Display
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showDetails ? 1.0 : 0.0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: widget.stats.map((stat) {
                            final baseStat = stat.baseStat ?? 0;
                            final statName = stat.stat?.name ?? 'Unknown';
                            return _buildStatCircle(statName, baseStat);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Physical Characteristics
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCharacteristic(
                        'Height',
                        '${widget.height / 10}m',
                        Icons.height,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCharacteristic(
                        'Weight',
                        '${widget.weight / 10}kg',
                        Icons.fitness_center,
                      ),
                    ),
                  ],
                ),
              ),

              // Abilities Section
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: secondaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abilities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (widget.abilities ?? []).map((abil) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: secondaryColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            abil.ability?.name ?? 'Unknown',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatColor(String statName) {
    // Harmonious color palette
    final Map<String, Color> statColors = {
      'hp': const Color(0xFFFF6B6B), // Coral red
      'attack': const Color(0xFFFFD93D), // Sunshine yellow
      'defense': const Color(0xFF6C5CE7), // Deep purple
      'special-attack': const Color(0xFFFF9FF3), // Soft pink
      'special-defense': const Color(0xFFA8A4FF), // Light purple
      'speed': const Color(0xFF00CEC9), // Turquoise
    };

    return statColors[statName.toLowerCase()] ?? Colors.grey;
  }

  Widget _buildStatCircle(String statName, int value) {
    final color = _getStatColor(statName);
    final size = 140.0; // Overall size of the circular gauge
    final progress = value / 200;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Progress Indicator
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: progress),
            builder: (context, double animatedValue, child) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: animatedValue, // Smooth animation
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 12, // Thicker ring
                ),
              );
            },
          ),

          // Inner Container with Value and Stat Name
          Container(
            width: size * 0.7, // Smaller inner circle
            height: size * 0.7,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.1), // Slightly transparent background
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.5), // Subtle border for contrast
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 22, // Larger font size for visibility
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatStatName(statName),
                  style: TextStyle(
                    fontSize: 12, // Smaller font size for stat name
                    color: Colors.white70, // Lighter color for secondary text
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristic(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secondaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: secondaryColor,
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatStatName(String name) {
    return name
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('\n');
  }
}
