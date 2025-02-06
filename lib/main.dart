import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poke/pages/home.dart';
import 'package:poke/services/favorite.dart';
import 'package:poke/services/http_service.dart';

void main() async {
  await _setup();
  runApp(ProviderScope(child: const MyApp()));
}

Future<void> _setup() async {
  GetIt.instance.registerSingleton<HttpService>(HttpService());
  GetIt.instance.registerSingleton<FavoriteList>(FavoriteList());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
          textTheme: GoogleFonts.latoTextTheme()),
      title: 'PokeApp',
      home: HomePage(),
    );
  }
}
