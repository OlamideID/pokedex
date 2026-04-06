import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poke/models/poke_type.dart';
import 'package:poke/services/http_service.dart';

const List<String> kAllTypeNames = [
  'normal',
  'fighting',
  'flying',
  'poison',
  'ground',
  'rock',
  'bug',
  'ghost',
  'steel',
  'fire',
  'water',
  'grass',
  'electric',
  'psychic',
  'ice',
  'dragon',
  'dark',
  'fairy',
];

// Fetches a single type by name
final pokemonTypeProvider = FutureProvider.family<PokemonType?, String>(
  (ref, typeName) async {
    final http = GetIt.instance.get<HttpService>();
    final Response? res =
        await http.get('https://pokeapi.co/api/v2/type/$typeName');
    if (res != null && res.data != null) {
      return PokemonType.fromJson(res.data);
    }
    return null;
  },
);

// Tracks which type is selected in the Types tab
final selectedTypeProvider = StateProvider<String?>((ref) => null);
