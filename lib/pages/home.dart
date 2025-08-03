import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/home_page_provider.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/providers/searchprov.dart';
import 'package:poke/utilities/favorites_list.dart';
import 'package:poke/widgets/pokemongriditem.dart';
import 'package:poke/widgets/searchbar.dart';

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

  static const double _scrollThreshold = 0.8;
  static const double _scrollToTopThreshold = 300.0;

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

  final homePageProv = StateNotifierProvider<HomePageProvider, HomePageData>(
    (ref) {
      return HomePageProvider(HomePageData.initial());
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: _buildBody(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showScrollToTop,
        builder: (context, showButton, _) => showButton
            ? IconButton(
                onPressed: _scrollToTop,
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildAppBar(),
        _buildSearchBar(),
        _buildFavoritesSection(),
        _buildPokemonGrid(context),
        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
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

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SearchBarr(
          controller: _searchController,
          onSearch: ref.read(pokemonSearchProvider.notifier).search,
          onClear: () {
            _searchController.clear();
            ref.read(pokemonSearchProvider.notifier).clearSearch();
          },
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Consumer(
      builder: (context, ref, _) {
        final favoritess = ref.watch(favorites);
        final searchQuery = ref
            .watch(pokemonSearchProvider.select((state) => state.searchQuery));

        if (favoritess.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final filteredFavorites =
            _getFilteredFavorites(favoritess, searchQuery);
        if (filteredFavorites.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: FavoritesListView(
            favorites: filteredFavorites,
            homePageData: ref.watch(homePageProv),
          ),
        );
      },
    );
  }

  Widget _buildPokemonGrid(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final searchState = ref.watch(pokemonSearchProvider);
        final results = searchState.filteredResults;

        if (results == null) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 800
                  ? 4
                  : MediaQuery.of(context).size.width > 650
                      ? 3
                      : 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: _buildGridDelegate(results),
          ),
        );
      },
    );
  }

  SliverChildBuilderDelegate _buildGridDelegate(
      List<PokemonListResult> results) {
    return SliverChildBuilderDelegate(
      (context, index) {
        if (index >= results.length) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isLoadingMore,
            builder: (context, isLoading, _) => isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : const SizedBox.shrink(),
          );
        }

        return PokemonGridItem(
          pokemon: results[index],
          onTap: _clearSearch,
          searchController: _searchController,
        );
      },
      childCount: results.length + 1,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(pokemonSearchProvider.notifier).clearSearch();
  }

  List<String> _getFilteredFavorites(
      List<String> favorites, String searchQuery) {
    if (searchQuery.isEmpty) return favorites;

    final filtered = ref.read(pokemonSearchProvider).filteredResults ?? [];
    return favorites.where((url) {
      final pokemon = filtered.firstWhere(
        (p) => p.url == url,
        orElse: () => PokemonListResult(name: 'Unknown', url: ''),
      );
      return pokemon.name?.toLowerCase().contains(searchQuery.toLowerCase()) ??
          false;
    }).toList();
  }
}
