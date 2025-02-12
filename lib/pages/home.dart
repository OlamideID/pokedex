import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/models/pokemon.dart';
// import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/home_page_provider.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/widgets/poke_card.dart';
import 'package:poke/widgets/pokemon_listtile.dart';

final homePageProv = StateNotifierProvider<HomePageProvider, HomePageData>(
  (ref) {
    return HomePageProvider(HomePageData.initial());
  },
);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late HomePageProvider _homePageProvider;
  late HomePageData _homePageData;
  final ScrollController controller = ScrollController();
  late List<String> _favorites;

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    controller.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent * 0.8 &&
        !controller.position.outOfRange) {
      _homePageProvider.loaddata();
    }
  }

  @override
  Widget build(BuildContext context) {
    _homePageProvider = ref.watch(homePageProv.notifier);
    _homePageData = ref.watch(homePageProv);
    _favorites = ref.watch(favorites);

    return Scaffold(
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
                          Colors.red[700]!.withOpacity(0.3), // more transparent
                          Colors.red[700]!.withOpacity(0.5), // more transparent
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_favorites.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildFavoritesSection(),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Pokémon',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_homePageData.data?.results?.length ?? 0} Pokémon',
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pokemon = _homePageData.data?.results?[index];
                  if (pokemon == null) return null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PokemonListTile(
                        pokemonUrl: pokemon.url!,
                        name: pokemon.name!,
                      ),
                    ),
                  );
                },
                childCount: _homePageData.data?.results?.length ?? 0,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (_favorites.isEmpty) return const SizedBox();
    print(height);
    print(width);

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
                _favorites.length > 1
                    ? '${_favorites.length} Pokémons'
                    : '${_favorites.length} Pokémon',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height / 3,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final pokemon = _homePageData.data?.results?.firstWhere(
                  (p) => p.url == _favorites[index],
                  orElse: () => PokemonListResult(name: 'Unknown', url: ''));

              return SizedBox(
                width: 160,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: PokeCard(
                    pokemonUrl: _favorites[index],
                    name: pokemon?.name ?? 'Unknown', // Handle null safely
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
