import 'package:flutter/material.dart';

class TypeColors {
  static const Map<String, Color> _colors = {
    'normal': Color(0xFFA8A77A),
    'fighting': Color(0xFFC22E28),
    'flying': Color(0xFFA98FF3),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFE2BF65),
    'rock': Color(0xFFB6A136),
    'bug': Color(0xFFA6B91A),
    'ghost': Color(0xFF735797),
    'steel': Color(0xFFB7B7CE),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'grass': Color(0xFF7AC74C),
    'electric': Color(0xFFF7D02C),
    'psychic': Color(0xFFF95587),
    'ice': Color(0xFF96D9D6),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'fairy': Color(0xFFD685AD),
    'stellar': Color(0xFF4FACFF),
    'unknown': Color(0xFF68A090),
  };

  static Color of(String type) =>
      _colors[type.toLowerCase()] ?? const Color(0xFFA8A77A);

  static Color textOn(String type) {
    final bg = of(type);
    final luminance = bg.computeLuminance();
    return luminance > 0.4 ? const Color(0xFF2C2C2C) : Colors.white;
  }
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

const kTypeColors = {
  'fire': Color(0xFFFF6B35),
  'water': Color(0xFF4A9EFF),
  'grass': Color(0xFF56C45A),
  'electric': Color(0xFFFFD93D),
  'psychic': Color(0xFFFF6B9D),
  'ice': Color(0xFF74D7EC),
  'dragon': Color(0xFF7038F8),
  'dark': Color(0xFF705848),
  'fairy': Color(0xFFEE99AC),
  'fighting': Color(0xFFC03028),
  'poison': Color(0xFFA040A0),
  'ground': Color(0xFFE0C068),
  'rock': Color(0xFFB8A038),
  'bug': Color(0xFFA8B820),
  'ghost': Color(0xFF705898),
  'steel': Color(0xFFB8B8D0),
  'normal': Color(0xFFA8A878),
  'flying': Color(0xFF89AAE3),
};

Color pokemonTypeColor(String? type) =>
    kTypeColors[type?.toLowerCase()] ?? const Color(0xFF7C3AED);
