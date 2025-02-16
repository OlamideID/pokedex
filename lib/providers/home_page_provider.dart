import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poke/models/page_data.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/services/http_service.dart';

class HomePageProvider extends StateNotifier<HomePageData> {
  final GetIt _getit = GetIt.instance;
  late HttpService _http;
  bool _isLoading = false; // Prevents duplicate API calls

  HomePageProvider(super._state) {
    _http = _getit.get<HttpService>();
    loaddata();
  }

  Future<void> loaddata() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      Response? response = await _http.get(state.data?.next ??
          'https://pokeapi.co/api/v2/pokemon?limit=20&offset=0');

      if (response != null) {
        PokemonListData newData = PokemonListData.fromJson(response.data);
        state = state.copyWith(
          data: state.data == null
              ? newData
              : state.data!.copyWith(
                  results: [...?state.data!.results, ...?newData.results],
                  next: newData.next),
        );
      }
    } catch (e) {
      print("Error loading data: $e");
    }

    _isLoading = false;
  }

  Future<void> loadMore() async {
    if (state.data?.next != null) {
      await loaddata(); // Calls the same function to fetch more data
    }
  }
}
