import 'package:flutter/material.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/widgets/poke_card.dart';

class FavoritesListView extends StatelessWidget {
  final List<String> favorites;
  final HomePageData homePageData;

  const FavoritesListView({super.key, 
    required this.favorites,
    required this.homePageData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Favorites',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => FavoriteCard(
              url: favorites[index],
              homePageData: homePageData,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
