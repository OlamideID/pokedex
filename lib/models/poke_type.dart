class PokemonType {
  final int id;
  final String name;
  final DamageRelations damageRelations;
  final List<TypePokemon> pokemon;

  PokemonType({
    required this.id,
    required this.name,
    required this.damageRelations,
    required this.pokemon,
  });

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      id: json['id'],
      name: json['name'],
      damageRelations: DamageRelations.fromJson(json['damage_relations']),
      pokemon: (json['pokemon'] as List)
          .map((e) => TypePokemon.fromJson(e))
          .toList(),
    );
  }
}

class DamageRelations {
  final List<TypeRef> noDamageTo;
  final List<TypeRef> halfDamageTo;
  final List<TypeRef> doubleDamageTo;
  final List<TypeRef> noDamageFrom;
  final List<TypeRef> halfDamageFrom;
  final List<TypeRef> doubleDamageFrom;

  DamageRelations({
    required this.noDamageTo,
    required this.halfDamageTo,
    required this.doubleDamageTo,
    required this.noDamageFrom,
    required this.halfDamageFrom,
    required this.doubleDamageFrom,
  });

  factory DamageRelations.fromJson(Map<String, dynamic> json) {
    return DamageRelations(
      noDamageTo: _parseList(json['no_damage_to']),
      halfDamageTo: _parseList(json['half_damage_to']),
      doubleDamageTo: _parseList(json['double_damage_to']),
      noDamageFrom: _parseList(json['no_damage_from']),
      halfDamageFrom: _parseList(json['half_damage_from']),
      doubleDamageFrom: _parseList(json['double_damage_from']),
    );
  }

  static List<TypeRef> _parseList(dynamic list) {
    if (list == null) return [];
    return (list as List).map((e) => TypeRef.fromJson(e)).toList();
  }
}

class TypeRef {
  final String name;
  final String url;

  TypeRef({required this.name, required this.url});

  factory TypeRef.fromJson(Map<String, dynamic> json) {
    return TypeRef(name: json['name'], url: json['url']);
  }
}

class TypePokemon {
  final int slot;
  final TypePokemonEntry pokemon;

  TypePokemon({required this.slot, required this.pokemon});

  factory TypePokemon.fromJson(Map<String, dynamic> json) {
    return TypePokemon(
      slot: json['slot'],
      pokemon: TypePokemonEntry.fromJson(json['pokemon']),
    );
  }
}

class TypePokemonEntry {
  final String name;
  final String url;

  TypePokemonEntry({required this.name, required this.url});

  factory TypePokemonEntry.fromJson(Map<String, dynamic> json) {
    return TypePokemonEntry(name: json['name'], url: json['url']);
  }
}
