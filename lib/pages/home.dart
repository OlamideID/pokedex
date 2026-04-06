import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/home_page_provider.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/providers/searchprov.dart';
import 'package:poke/widgets/pokemongriditem.dart';
import 'package:poke/widgets/searchbar.dart';
import 'package:poke/widgets/types_tab.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _isLoadingMore = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier<bool>(false);

  int _selectedTab = 0;

  static const double _scrollThreshold = 0.8;
  static const double _scrollToTopThreshold = 300.0;
  static const Color _accent = Color(0xFF7C3AED);
  static const Color _bg = Color(0xFF1A1A2E);

  final homePageProv = StateNotifierProvider<HomePageProvider, HomePageData>(
    (ref) => HomePageProvider(HomePageData.initial()),
  );

  static const _navItems = [
    _NavItem(icon: Icons.catching_pokemon_rounded, label: 'Home'),
    _NavItem(icon: Icons.grid_view_rounded, label: 'Types'),
    _NavItem(icon: Icons.favorite_rounded, label: 'Favorites'),
  ];

  @override
  void initState() {
    super.initState();
    _setupScrollController();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      _handleInfiniteScroll();
      _handleScrollToTopButton();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _isLoadingMore.dispose();
    _showScrollToTop.dispose();
    super.dispose();
  }

  Future<void> _handleInfiniteScroll() async {
    if (!_shouldLoadMore()) return;
    _isLoadingMore.value = true;
    await ref.read(pokemonSearchProvider.notifier).loadMore();
    _isLoadingMore.value = false;
  }

  bool _shouldLoadMore() {
    return _scrollController.offset >=
            _scrollController.position.maxScrollExtent * _scrollThreshold &&
        !_scrollController.position.outOfRange &&
        !_isLoadingMore.value;
  }

  void _handleScrollToTopButton() {
    _showScrollToTop.value = _scrollController.offset > _scrollToTopThreshold;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(pokemonSearchProvider.notifier).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: _selectedTab == 0
          ? ValueListenableBuilder<bool>(
              valueListenable: _showScrollToTop,
              builder: (context, showButton, _) => showButton
                  ? IconButton(
                      onPressed: _scrollToTop,
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                    )
                  : const SizedBox.shrink(),
            )
          : null,
      body: BottomBar(
        clip: Clip.none,
        fit: StackFit.expand,
        borderRadius: BorderRadius.circular(28),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width - 48,
        offset: 10,
        barDecoration: BoxDecoration(
          color: const Color(0xFF1E1A38),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF2C2850)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = _selectedTab == i;
              const unselectedColor = Color(0xFF6B5FA0);

              return GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: selected ? _accent : unselectedColor,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: selected
                            ? Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _accent,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // FIX: Use IndexedStack to preserve tab state and avoid rebuilding
        // tabs from scratch on every switch.
        body: (context, controller) => IndexedStack(
          index: _selectedTab,
          children: [
            _PokedexTab(
              scrollController: _scrollController,
              searchController: _searchController,
              isLoadingMore: _isLoadingMore,
              onClearSearch: _clearSearch,
            ),
            const TypesTab(),
            _FavoritesTab(homePageProv: homePageProv),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _PokedexTab extends ConsumerWidget {
  final ScrollController scrollController;
  final TextEditingController searchController;
  final ValueNotifier<bool> isLoadingMore;
  final VoidCallback onClearSearch;

  const _PokedexTab({
    required this.scrollController,
    required this.searchController,
    required this.isLoadingMore,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      controller: scrollController,
      // FIX: Caching extent keeps items alive longer in the scroll direction,
      // reducing expensive build/destroy cycles near the visible boundary.
      cacheExtent: 500,
      slivers: [
        _buildAppBar(),
        _buildSearchBar(ref),
        _buildPokemonList(context, ref),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 32,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              color: Colors.white.withOpacity(0.3),
              colorBlendMode: BlendMode.modulate,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple[900]!.withOpacity(0.8),
                    Colors.red[900]!.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SearchBarr(
          controller: searchController,
          onSearch: ref.read(pokemonSearchProvider.notifier).search,
          onClear: () {
            searchController.clear();
            ref.read(pokemonSearchProvider.notifier).clearSearch();
          },
        ),
      ),
    );
  }

  Widget _buildPokemonList(BuildContext context, WidgetRef ref) {
    // FIX: Use select() to only rebuild when filteredResults reference changes,
    // not on every search state property change (e.g. isLoading, query, etc).
    final results = ref.watch(
      pokemonSearchProvider.select((s) => s.filteredResults),
    );

    if (results == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= results.length) {
            return ValueListenableBuilder<bool>(
              valueListenable: isLoadingMore,
              builder: (context, loading, _) => loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: Colors.white54, strokeWidth: 2),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }
          // FIX: RepaintBoundary isolates each tile into its own layer.
          // Shimmer animations and data updates in one tile won't trigger
          // repaints in neighbouring tiles.
          return RepaintBoundary(
            child: PokemonGridItem(
              pokemon: results[index],
              onTap: onClearSearch,
              searchController: searchController,
              index: index,
            ),
          );
        },
        childCount: results.length + 1,
        // FIX: Disabling automatic keep-alives means offscreen tiles can be
        // garbage-collected. Re-enables fast GC when the list is long.
        addAutomaticKeepAlives: false,
        // Keep repaint boundaries enabled (default true) — explicit for clarity.
        addRepaintBoundaries: true,
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  final StateNotifierProvider<HomePageProvider, HomePageData> homePageProv;
  const _FavoritesTab({required this.homePageProv});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritess = ref.watch(favorites);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF1A1A2E),
          title: Row(
            children: [
              const Text(
                'Saved',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (favoritess.isNotEmpty) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF7C3AED).withOpacity(0.4)),
                  ),
                  child: Text(
                    '${favoritess.length}',
                    style: const TextStyle(
                      color: Color(0xFF9B7FE8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.white.withOpacity(0.08)),
          ),
        ),
        if (favoritess.isEmpty)
          const SliverFillRemaining(child: _EmptyFavorites())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final url = favoritess[index];
                  // FIX: RepaintBoundary per card — shimmer animations won't
                  // dirty the whole grid.
                  return RepaintBoundary(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final pokAsync = ref.watch(pokemonData(url));
                        return pokAsync.when(
                          data: (pokemon) {
                            if (pokemon == null) return const SizedBox.shrink();
                            return _FavoriteCard(
                              pokemon: pokemon,
                              url: url,
                              index: index,
                            );
                          },
                          loading: () => const _FavoriteCardShimmer(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  );
                },
                childCount: favoritess.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
              ),
            ),
          ),
      ],
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  final Pokemon pokemon;
  final String url;
  final int index;

  const _FavoriteCard({
    required this.pokemon,
    required this.url,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryType = pokemon.types?.firstOrNull?.type?.name;
    const _favoriteTypeColors = {
      'fire': Color(0xFFFF6B35),
      'water': Color(0xFF4A9EFF),
      'grass': Color(0xFF56C45A),
      'electric': Color(0xFFFFD93D),
      'psychic': Color(0xFFFF6B9D),
      'ice': Color(0xFF74D7EC),
      'dragon': Color(0xFF7038F8),
      'dark': Color(0xFF705848),
      'fairy': Color(0xFFEE99AC),
      'fighting': Color(0xFFC03028),
      'poison': Color(0xFFA040A0),
      'ground': Color(0xFFE0C068),
      'rock': Color(0xFFB8A038),
      'bug': Color(0xFFA8B820),
      'ghost': Color(0xFF705898),
      'steel': Color(0xFFB8B8D0),
      'normal': Color(0xFFA8A878),
      'flying': Color(0xFF89AAE3),
    };

    Color typeColor0(String? type) =>
        _favoriteTypeColors[type?.toLowerCase()] ?? const Color(0xFF7C3AED);
    final typeColor = typeColor0(primaryType);
    final dex = '#${(pokemon.id ?? index + 1).toString().padLeft(3, '0')}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
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
              'pokemonUrlDetails': url,
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16152A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: typeColor.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.08),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                    ),
                    Center(
                      child: Hero(
                        tag: url,
                        child: pokemon.sprites?.frontDefault != null
                            ? CachedNetworkImage(
                                imageUrl: pokemon.sprites!.frontDefault!,
                                fit: BoxFit.contain,
                                placeholder: (_, __) => const SizedBox.shrink(),
                                errorWidget: (_, __, ___) => const Icon(
                                    Icons.catching_pokemon,
                                    color: Colors.white24,
                                    size: 40),
                              )
                            : const Icon(Icons.catching_pokemon,
                                color: Colors.white24, size: 40),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () =>
                            ref.read(favorites.notifier).removeFavorite(url),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.redAccent,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 10,
                      child: Text(
                        dex,
                        style: TextStyle(
                          color: typeColor.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalizeName(pokemon.name ?? ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (pokemon.types != null)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: pokemon.types!
                              .take(2)
                              .map((t) => _MiniTypeChip(
                                    label: t.type?.name ?? '',
                                    color: typeColor0(t.type?.name),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeName(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _MiniTypeChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTypeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// FIX: _FavoriteCardShimmer now uses a simple repeating AnimationController
// instead of AnimationController.unbounded. The unbounded variant with
// repeat(min:, max:) does extra math every tick — a plain looping controller
// is lighter when many shimmer cards are on screen simultaneously.
class _FavoriteCardShimmer extends StatefulWidget {
  const _FavoriteCardShimmer();

  @override
  State<_FavoriteCardShimmer> createState() => _FavoriteCardShimmerState();
}

class _FavoriteCardShimmerState extends State<_FavoriteCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // FIX: Plain repeat() instead of unbounded — less overhead per tick.
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16152A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF2A2845),
                      Color(0xFF3A3860),
                      Color(0xFF2A2845)
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment(-1.0 + _controller.value * 2, 0),
                    end: Alignment(1.0 + _controller.value * 2, 0),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) => Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: const [
                            Color(0xFF2A2845),
                            Color(0xFF3A3860),
                            Color(0xFF2A2845)
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment(-1.0 + _controller.value * 2, 0),
                          end: Alignment(1.0 + _controller.value * 2, 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) => Container(
                      height: 10,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: const [
                            Color(0xFF2A2845),
                            Color(0xFF3A3860),
                            Color(0xFF2A2845)
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment(-1.0 + _controller.value * 2, 0),
                          end: Alignment(1.0 + _controller.value * 2, 0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart on any Pokémon\nto add it here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
