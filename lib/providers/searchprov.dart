import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poke/models/pokemon.dart';
// import 'package:poke/models/page_data.dart';
import 'package:poke/services/http_service.dart';

// Define a class to hold both the original and filtered Pokemon lists
class PokemonSearchState {
  final PokemonListData? originalData;
  final List<PokemonListResult>? filteredResults;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  PokemonSearchState({
    this.originalData,
    this.filteredResults,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  PokemonSearchState copyWith({
    PokemonListData? originalData,
    List<PokemonListResult>? filteredResults,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return PokemonSearchState(
      originalData: originalData ?? this.originalData,
      filteredResults: filteredResults ?? this.filteredResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PokemonSearchNotifier extends StateNotifier<PokemonSearchState> {
  final GetIt _getIt = GetIt.instance;
  late HttpService _http;

  // Cache for storing detailed Pokemon data
  final Map<String, Pokemon> _pokemonCache = {};

  PokemonSearchNotifier() : super(PokemonSearchState()) {
    _http = _getIt.get<HttpService>();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      Response? response = await _http
          .get('https://pokeapi.co/api/v2/pokemon?limit=1304&offset=0');

      if (response != null) {
        final data = PokemonListData.fromJson(response.data);
        state = state.copyWith(
          originalData: data,
          filteredResults: data.results,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load Pokemon data: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.originalData?.next == null || state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true);

      Response? response = await _http.get(state.originalData!.next!);

      if (response != null) {
        final newData = PokemonListData.fromJson(response.data);
        final updatedData = state.originalData!.copyWith(
          results: [...?state.originalData!.results, ...?newData.results],
          next: newData.next,
        );

        state = state.copyWith(
          originalData: updatedData,
          filteredResults:
              _filterResults(state.searchQuery, updatedData.results),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more Pokemon: $e',
      );
    }
  }

  Future<Pokemon?> getPokemonDetails(String url) async {
    // Check cache first
    if (_pokemonCache.containsKey(url)) {
      return _pokemonCache[url];
    }

    try {
      Response? response = await _http.get(url);
      if (response != null) {
        final pokemon = Pokemon.fromJson(response.data);
        // Store in cache
        _pokemonCache[url] = pokemon;
        return pokemon;
      }
    } catch (e) {
      print('Error fetching Pokemon details: $e');
    }
    return null;
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredResults: _filterResults(query, state.originalData?.results),
    );
  }

  List<PokemonListResult>? _filterResults(
      String query, List<PokemonListResult>? results) {
    if (query.isEmpty) return results;
    if (results == null) return null;

    final lowercaseQuery = query.toLowerCase();
    return results.where((pokemon) {
      return pokemon.name?.toLowerCase().contains(lowercaseQuery) ?? false;
    }).toList();
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      filteredResults: state.originalData?.results,
    );
  }

  void clearCache() {
    _pokemonCache.clear();
  }
}

// Provider definition
final pokemonSearchProvider =
    StateNotifierProvider<PokemonSearchNotifier, PokemonSearchState>((ref) {
  return PokemonSearchNotifier();
});
