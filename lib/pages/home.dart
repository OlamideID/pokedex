import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/home_page_provider.dart';
import 'package:poke/providers/pokemon_provider.dart';
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
    if (controller.offset >= controller.position.maxScrollExtent * 1 &&
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
      body: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
        child: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width * 0.2),
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_pokemonList(context)],
        ),
      ),
    ));
  }

  Widget _pokemonList(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Pokemons',
            style: TextStyle(fontSize: 25),
          ),
          SizedBox(
            height: height * 0.6,
            child: ListView.separated(
              controller: controller,
              separatorBuilder: (context, index) => SizedBox(
                height: 10,
              ),
              itemCount: _homePageData.data?.results?.length ?? 0,
              itemBuilder: (context, index) {
                PokemonListResult result = _homePageData.data!.results![index];
                return PokemonListtile(pokemonUrl: result.url!);
              },
            ),
          )
        ],
      ),
    );
  }
}
