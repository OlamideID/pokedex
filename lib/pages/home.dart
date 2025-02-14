import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/home_page_provider.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/providers/searchprov.dart';
import 'package:poke/widgets/poke_card.dart';
import 'package:poke/widgets/pokemon_listtile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late HomePageData _homePageData;
  final ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMore = false;
  bool _showScrollToTopButton = false; // Added state

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent * 0.8 &&
        !controller.position.outOfRange &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);

      await ref.read(pokemonSearchProvider.notifier).loadMore();

      setState(() => _isLoadingMore = false);
    }

    // Show scroll-to-top button when scrolled down
    if (controller.offset > 300) {
      if (!_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = true);
      }
    } else {
      if (_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = false);
      }
    }
  }

  void _scrollToTop() {
    controller.animateTo(
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

  List<String> _getFilteredFavorites(
      List<String> favorites, String searchQuery) {
    if (searchQuery.isEmpty) return favorites;

    final filtered = ref.watch(pokemonSearchProvider).filteredResults ?? [];

    return favorites.where((favoriteUrl) {
      final pokemon = filtered.firstWhere(
        (p) => p.url == favoriteUrl,
        orElse: () => PokemonListResult(name: 'Unknown', url: ''),
      );
      return pokemon.name!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    _homePageData = ref.watch(homePageProv);
    final favoritess = ref.watch(favorites);
    final searchState = ref.watch(pokemonSearchProvider);

    final filteredFavorites =
        _getFilteredFavorites(favoritess, searchState.searchQuery);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: _showScrollToTopButton
          ? IconButton(
              onPressed: _scrollToTop,
              // backgroundColor: Colors.red[700],
              icon: Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            )
          : null,
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: controller,
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.red[700],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: const Text(
                'Pokédex',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/poke-ball.png',
                    fit: BoxFit.none,
                    alignment: Alignment.centerRight,
                    opacity: const AlwaysStoppedAnimation(0.2),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.red[700]!.withOpacity(0.3),
                          Colors.red[700]!.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Pokémon...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(pokemonSearchProvider.notifier)
                                .clearSearch();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  ref.read(pokemonSearchProvider.notifier).search(value);
                },
              ),
            ),
          ),
          if (filteredFavorites.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildFavoritesSection(filteredFavorites),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      searchState.searchQuery.isEmpty
                          ? 'All Pokémon'
                          : 'Search Results',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      searchState.searchQuery.isEmpty
                          ? ''
                          : '${searchState.filteredResults?.length ?? 0} Pokémon',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),

          if (searchState.error != null)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    searchState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (searchState.filteredResults == null) return null;

                    if (index >= searchState.filteredResults!.length) {
                      return _isLoadingMore || searchState.isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : null;
                    }

                    final pokemon = searchState.filteredResults![index];
                    if (pokemon.url == null || pokemon.name == null) {
                      return null;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PokemonListTile(
                        pokemonUrl: pokemon.url!,
                        name: pokemon.name!,
                      ),
                    );
                  },
                  childCount: (searchState.filteredResults?.length ?? 0) +
                      ((searchState.isLoading || _isLoadingMore) ? 1 : 0),
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection(List<String> filteredFavorites) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${filteredFavorites.length} Pokémon',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height / 3.7,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredFavorites.length,
            itemBuilder: (context, index) {
              final pokemon = _homePageData.data?.results?.firstWhere(
                (p) => p.url == filteredFavorites[index],
                orElse: () =>
                    PokemonListResult(name: 'Pokémon #${index + 1}', url: ''),
              );

              return SizedBox(
                width: 160,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: PokeCard(
                    pokemonUrl: filteredFavorites[index],
                    name: pokemon?.name ?? '',
                  ),
                ),
              );
            },
          ),
        ),
        // const SizedBox(height: 8),
      ],
    );
  }
}
