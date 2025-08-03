import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/services/favorite.dart';
import 'package:poke/services/http_service.dart';

final pokemonData = FutureProvider.family<Pokemon?, String>((ref, url) async {
  HttpService http = GetIt.instance.get<HttpService>();
  Response? res = await http.get(url);
  if (res != null && res.data != null) {
    return Pokemon.fromJson(res.data);
  }
  return null;
});

final favorites = StateNotifierProvider<Favorites, List<String>>(
  (ref) {
    return Favorites([]);
  },
);

class Favorites extends StateNotifier<List<String>> {
  final FavoriteList _favoriteList = GetIt.instance.get<FavoriteList>();

  String favoritekey = 'Nice_Key';

  Favorites(super.state) {
    _setup();
  }

  Future<void> _setup() async {
    List<String>? data = await _favoriteList.get(favoritekey);
    if (data != null) {
      state = data;
    } else {
      state = [];
    }
  }

  void addFavorite(String url) {
    state = [...state, url];
    _favoriteList.save(favoritekey, state);
  }

  void removeFavorite(String url) {
    state = state.where((element) => element != url).toList();
    _favoriteList.save(favoritekey, state);
  }
}
