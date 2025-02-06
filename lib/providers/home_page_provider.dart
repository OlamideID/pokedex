import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/services/http_service.dart';

class HomePageProvider extends StateNotifier<HomePageData> {
  final GetIt _getit = GetIt.instance;
  late HttpService _http;

  HomePageProvider(super._state) {
    _http = _getit.get<HttpService>();
    loaddata();
  }

  Future<void> loaddata() async {
    try {
      if (state.data == null) {
        Response? response = await _http
            .get('https://pokeapi.co/api/v2/pokemon?limit=20&offset=0');
        if (response != null) {
          state = state.copyWith(data: PokemonListData.fromJson(response.data));
        }
      } else if (state.data!.next != null) {
        Response? response = await _http.get(state.data!.next!);
        if (response != null) {
          PokemonListData data = PokemonListData.fromJson(response.data);
          state = state.copyWith(
            data: state.data!.copyWith(
                results: [...?state.data!.results, ...?data.results],
                next: data.next),
          );
        }
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }
}
