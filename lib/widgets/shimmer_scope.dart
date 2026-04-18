import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/providers/searchprov.dart';
import 'package:poke/utilities/type_colors.dart';

class ShimmerScope extends StatefulWidget {
  final Widget child;
  const ShimmerScope({super.key, required this.child});

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();

  static AnimationController of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedShimmer>();
    assert(inherited != null, 'No ShimmerScope found in widget tree');
    return inherited!.controller;
  }
}

class _ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedShimmer(
      controller: _controller,
      child: widget.child,
    );
  }
}

class _InheritedShimmer extends InheritedWidget {
  final AnimationController controller;
  const _InheritedShimmer({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedShimmer old) => false;
}

// ---------------------------------------------------------------------------
// PokemonListTile
// ---------------------------------------------------------------------------
class PokemonListTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: select() — only rebuilds when THIS url's favorite status changes,
    // not on every add/remove anywhere in the favorites list.
    final isFavorite = ref.watch(
      favorites.select((f) => f.contains(pokemonUrl)),
    );

    return ref.watch(pokemonData(pokemonUrl)).when(
          data: (pokemon) => pokemon == null
              ? _buildErrorTile()
              : _PokemonCard(
                  pokemon: pokemon,
                  pokemonUrl: pokemonUrl,
                  isFavorite: isFavorite,
                  index: index,
                  controller: controller,
                  onTap: onTap,
                ),
          error: (_, __) => _buildErrorTile(),
          // FIX: No longer creates an AnimationController here —
          // pulls from the shared ShimmerScope instead.
          loading: () => _PokemonShimmer(index: index),
        );
  }

  Widget _buildErrorTile() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: SizedBox(height: 90),
      );
}

// ---------------------------------------------------------------------------
// Card — separated so ConsumerWidget only rebuilds the card subtree.
// ---------------------------------------------------------------------------
class _PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;
  final String pokemonUrl;
  final bool isFavorite;
  final int index;
  final TextEditingController controller;
  final VoidCallback? onTap;

  const _PokemonCard({
    required this.pokemon,
    required this.pokemonUrl,
    required this.isFavorite,
    required this.index,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryType = pokemon.types?.firstOrNull?.type?.name;
    final color = pokemonTypeColor(primaryType);
    final dex = '#${(index + 1).toString().padLeft(3, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToDetails(context, ref, pokemon),
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
                  tag: pokemonUrl,
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
                // FIX: RepaintBoundary isolates the heart icon repaint from
                // the rest of the tile (sprite, name, chips stay untouched).
                RepaintBoundary(
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(ref),
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _toggleFavorite(WidgetRef ref) {
    final notifier = ref.read(favorites.notifier);
    if (ref.read(favorites).contains(pokemonUrl)) {
      notifier.removeFavorite(pokemonUrl);
    } else {
      notifier.addFavorite(pokemonUrl);
    }
  }

  void _navigateToDetails(
      BuildContext context, WidgetRef ref, Pokemon pokemon) {
    onTap?.call();
    ref.read(pokemonSearchProvider.notifier).clearSearch();
    controller.clear();
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
        'pokemonUrlDetails': pokemonUrl,
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer — reads from ShimmerScope, no owned AnimationController.
// ---------------------------------------------------------------------------
class _PokemonShimmer extends StatelessWidget {
  final int index;
  const _PokemonShimmer({required this.index});

  @override
  Widget build(BuildContext context) {
    // FIX: Single shared controller from ShimmerScope — zero extra tickers.
    final animation = ShimmerScope.of(context);

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
            _ShimmerBox(
                animation: animation, width: 64, height: 64, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(animation: animation, width: 60, height: 10),
                  const SizedBox(height: 6),
                  _ShimmerBox(animation: animation, width: 120, height: 14),
                  const SizedBox(height: 8),
                  _ShimmerBox(animation: animation, width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends AnimatedWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required Animation<double> animation,
    required this.width,
    required this.height,
    this.radius = 6,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: const [
            Color(0xFF2A2845),
            Color(0xFF3A3860),
            Color(0xFF2A2845),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0 + t * 2, 0),
          end: Alignment(1.0 + t * 2, 0),
        ),
      ),
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
