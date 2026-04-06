import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/providers/searchprov.dart';
import 'package:poke/utilities/type_colors.dart';

class PokemonListTile extends ConsumerStatefulWidget {
  const PokemonListTile({
    super.key,
    required this.pokemonUrl,
    required this.name,
    required this.controller,
    required this.index,
    this.onTap,
  });

  final String pokemonUrl;
  final String name;
  final TextEditingController controller;
  final int index;
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
    // FIX: Plain repeat() instead of AnimationController.unbounded with
    // repeat(min:, max:). Unbounded does extra interpolation math every
    // frame — a simple 0→1 loop is cheaper when 20+ tiles are on screen.
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Use select() to subscribe only to whether THIS url is a favorite.
    // Without select(), any change to the favorites list (adding/removing any
    // pokemon) would rebuild every visible PokemonListTile. With select(),
    // only the tile whose url changed will rebuild.
    final isFavorite = ref.watch(
      favorites.select((f) => f.contains(widget.pokemonUrl)),
    );

    return ref.watch(pokemonData(widget.pokemonUrl)).when(
          data: (pokemon) => pokemon == null
              ? _buildErrorTile()
              : _buildCard(pokemon, isFavorite),
          error: (_, __) => _buildErrorTile(),
          loading: _buildShimmer,
        );
  }

  Widget _buildCard(Pokemon pokemon, bool isFavorite) {
    final primaryType = pokemon.types?.firstOrNull?.type?.name;
    final color = pokemonTypeColor(primaryType);
    final dex = '#${(widget.index + 1).toString().padLeft(3, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToDetails(pokemon),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF16152A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.25), width: 1),
            ),
            child: Row(
              children: [
                // Type accent bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(20)),
                  ),
                ),
                const SizedBox(width: 14),
                // Sprite
                Hero(
                  tag: widget.pokemonUrl,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: pokemon.sprites?.frontDefault != null
                        ? CachedNetworkImage(
                            imageUrl: pokemon.sprites!.frontDefault!,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox.shrink(),
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.catching_pokemon,
                                color: Colors.white24),
                          )
                        : const Icon(Icons.catching_pokemon,
                            color: Colors.white24),
                  ),
                ),
                const SizedBox(width: 14),
                // Name + types
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dex,
                        style: TextStyle(
                          color: color.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _capitalize(pokemon.name ?? ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (pokemon.types != null)
                        Row(
                          children: pokemon.types!
                              .take(2)
                              .map((t) => _TypeChip(
                                    label: t.type?.name ?? '',
                                    color: pokemonTypeColor(t.type?.name),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
                // FIX: Wrap favorite icon in its own RepaintBoundary so that
                // toggling the heart only repaints this small icon area, not
                // the entire tile row (sprite, name, type chips, etc).
                RepaintBoundary(
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.redAccent : Colors.white30,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF16152A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2845),
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(20)),
              ),
            ),
            const SizedBox(width: 14),
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (_, __) => Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF2A2845),
                      Color(0xFF3A3860),
                      Color(0xFF2A2845)
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment(-1.0 + _shimmerController.value * 2, 0),
                    end: Alignment(1.0 + _shimmerController.value * 2, 0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(60, 10),
                  const SizedBox(height: 6),
                  _shimmerBox(120, 14),
                  const SizedBox(height: 8),
                  _shimmerBox(80, 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double w, double h) => AnimatedBuilder(
        animation: _shimmerController,
        builder: (_, __) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: const [
                Color(0xFF2A2845),
                Color(0xFF3A3860),
                Color(0xFF2A2845)
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _shimmerController.value * 2, 0),
              end: Alignment(1.0 + _shimmerController.value * 2, 0),
            ),
          ),
        ),
      );

  Widget _buildErrorTile() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: SizedBox(height: 90),
      );

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _toggleFavorite() {
    final notifier = ref.read(favorites.notifier);
    if (ref.read(favorites).contains(widget.pokemonUrl)) {
      notifier.removeFavorite(widget.pokemonUrl);
    } else {
      notifier.addFavorite(widget.pokemonUrl);
    }
  }

  void _navigateToDetails(Pokemon pokemon) {
    widget.onTap?.call();
    ref.read(pokemonSearchProvider.notifier).clearSearch();
    widget.controller.clear();
    context.goNamed(
      'pokemon-details',
      pathParameters: {'name': pokemon.name?.toLowerCase() ?? 'unknown'},
      extra: {
        'id': pokemon.id,
        'height': pokemon.height ?? 0,
        'weight': pokemon.weight ?? 0,
        'abilities': pokemon.abilities?.toList() ?? [],
        'ability': pokemon.species ?? Ability(name: 'Unknown'),
        'image1': pokemon.sprites?.frontShiny ?? '',
        'image2': pokemon.sprites?.backShiny ?? '',
        'stats': pokemon.stats?.toList() ?? [],
        'moves': (pokemon.moves?.length ?? 0).toString(),
        'species': pokemon.species?.name ?? 'Unknown',
        'pokemonUrlDetails': widget.pokemonUrl,
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.45), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final PokemonListResult pokemon;
  final VoidCallback onTap;
  final TextEditingController searchController;
  final int index;

  const PokemonCard({
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
